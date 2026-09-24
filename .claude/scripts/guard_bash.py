"""Block destructive shell commands before Claude Code runs them.

Evaluator for the PreToolUse Bash hook, started by guard-bash.sh (which blocks
whenever this script cannot run). Reads the hook JSON on stdin. Exits 2 with a
reason on stderr to block, and 0 to allow. Anything it cannot parse is blocked.

Two layers:
  1. A structured pass that reads the command the way bash does. A quote-aware
     scan drops comments and heredoc bodies fed to non-shell commands, and
     pulls out $(...) / backtick bodies hidden inside double quotes. shlex then
     splits commands on ; & | ( ) ` and newlines outside quotes, and keywords
     (if, do, !, ...) and wrappers (sudo, env, rtk, timeout, ...) are peeled
     off. `bash -c`, `eval` and here-strings fed to a shell are evaluated
     recursively, and each command is checked against the rules.
  2. A backstop that re-checks the code-only text (quoted strings, comments
     and data heredocs removed) word by word, so a construct the structured
     pass misses still blocks instead of being silently allowed.

Scope: accidents, not adversarial evasion. See guard-bash.sh for the known
unhandled spellings.
"""

from __future__ import annotations

import getpass
import json
import os
import re
import shlex
import subprocess
import sys
from collections.abc import Iterator
from dataclasses import dataclass, field
from pathlib import Path, PurePosixPath
from typing import cast

HOME = str(Path.home()).rstrip("/") or "/"
SHELLS = {"bash", "sh", "zsh", "dash", "ksh", "fish", "tcsh", "mksh"}
KEYWORDS = {
    "if",
    "then",
    "else",
    "elif",
    "fi",
    "do",
    "done",
    "while",
    "until",
    "!",
    "{",
    "}",
    "time",
}
PROTECTED_BRANCHES = {"main", "master"}
MAX_DEPTH = 5
PUNCTUATION = ";&|()<>`\n"

# Wrapper command -> its options that take a separate argument.
WRAPPERS: dict[str, set[str]] = {
    "sudo": {"-u", "-g", "-h", "-p", "-C", "-D", "-R", "-T", "-U", "-r", "-t"},
    "doas": {"-u", "-C"},
    "env": {"-u", "-C", "-P", "-S"},
    "command": set(),
    "builtin": set(),
    "exec": {"-a"},
    "nohup": set(),
    "nice": {"-n"},
    "timeout": {"-s", "-k", "--signal", "--kill-after"},
    "gtimeout": {"-s", "-k", "--signal", "--kill-after"},
    "xargs": {"-I", "-L", "-n", "-P", "-s", "-E", "-d", "-a"},
    "stdbuf": {"-i", "-o", "-e"},
    "caffeinate": {"-t", "-w"},
}
TAKES_DURATION = {"timeout", "gtimeout"}
SHELL_OPTS_WITH_VALUE = {"-o", "-O", "+o", "+O", "--rcfile", "--init-file"}
GIT_OPTS_WITH_VALUE = {
    "-C",
    "-c",
    "--git-dir",
    "--work-tree",
    "--namespace",
    "--super-prefix",
    "--config-env",
}
PUSH_OPTS_WITH_VALUE = {"-o", "--push-option", "--repo", "--receive-pack", "--exec"}

HEREDOC_START = re.compile(r"<<(-?)\s*(['\"]?)([\w.\-]+)\2")
# A shell, eval, source or `.` word in the unquoted text of a heredoc's line
# (or $SHELL) means its body may execute.
SHELL_WORD = re.compile(
    r"(?:^|[\s;&|(`\"'$/])(?:bash|sh|zsh|dash|ksh|fish|tcsh|mksh|eval|source|\.)"
    r"(?:$|[\s;&|)`\"'<])|\$\{?SHELL\b"
)

# Escapes in $'...' that change what a command runs; others stay as written.
ANSI_C_ESCAPE = re.compile(r"\\(.)", re.S)
ANSI_C_CHARS = {"n": "\n", "t": "\t", "r": "\r", "\\": "\\", "'": "'", '"': '"'}

CODE, SQ, DQ, SUBST, BT, ANSI = (
    "code",
    "single",
    "double",
    "subst",
    "backtick",
    "ansi-c",
)


class Blocked(Exception):
    """Raised with the reason a command is destructive."""


@dataclass
class Frame:
    state: str
    start: int
    in_dq: bool = False
    depth: int = 0
    arith: bool = False


class Scan:
    """One quote-aware pass over a command string.

    Records the spans to drop (comments; heredoc bodies fed to non-shell
    commands, and every heredoc terminator), the quoted spans, and the bodies
    of command substitutions inside double quotes, which run even though the
    lexer sees them as part of one quoted word.
    """

    def __init__(self, text: str) -> None:
        self.text: str = text
        self.drop: list[tuple[int, int, str]] = []
        self.expand: list[tuple[int, int]] = []
        self.quoted: list[tuple[int, int]] = []
        self.subst: list[tuple[int, int]] = []
        self.heredocs: list[tuple[str, bool]] = []
        self.stack: list[Frame] = [Frame(CODE, 0)]
        i = 0
        while i < len(text):
            i = self.step(i)

    def step(self, i: int) -> int:
        frame, ch = self.stack[-1], self.text[i]
        if frame.state == SQ:
            if ch == "'":
                self.pop(i + 1)
            return i + 1
        if frame.state == ANSI:
            if ch == "\\":
                return i + 2
            if ch == "'":
                body = self.text[frame.start + 2 : i]
                self.drop.append((frame.start, i + 1, ansi_c(body)))
                self.stack.pop()
            return i + 1
        if ch == "\\":
            return i + 2
        if frame.state == DQ:
            return self.in_double(i)
        return self.in_code(i, frame)

    def push(
        self, state: str, start: int, in_dq: bool = False, arith: bool = False
    ) -> None:
        self.stack.append(Frame(state, start, in_dq, arith=arith))

    def pop(self, end: int) -> None:
        frame = self.stack.pop()
        if frame.state in (SQ, DQ):
            self.quoted.append((frame.start, end))
        elif frame.in_dq:
            self.subst.append((frame.start, end))

    def in_double(self, i: int) -> int:
        text = self.text
        if text[i] == '"':
            self.pop(i + 1)
        elif text.startswith("$(", i):
            self.push(SUBST, i + 2, in_dq=True, arith=text.startswith("$((", i))
            return i + 2
        elif text[i] == "`":
            self.push(BT, i + 1, in_dq=True)
        return i + 1

    def in_code(self, i: int, frame: Frame) -> int:
        text, ch = self.text, self.text[i]
        if text.startswith("$'", i):
            self.push(ANSI, i)
            return i + 2
        if ch in "'\"":
            self.push(SQ if ch == "'" else DQ, i)
        elif (
            ch == "#"
            and (i == 0 or text[i - 1] in " \t\n;&|(")
            and not (i >= 2 and text[i - 2] == "\\")
        ):
            end = text.find("\n", i)
            end = len(text) if end < 0 else end
            self.drop.append((i, end, ""))
            return end
        elif text.startswith("$(", i):
            self.push(SUBST, i + 2, arith=text.startswith("$((", i))
            return i + 2
        elif ch == "`":
            if frame.state == BT:
                self.pop(i)
            else:
                self.push(BT, i + 1)
        elif frame.state == SUBST and ch in "()":
            if ch == "(":
                frame.depth += 1
            elif frame.depth:
                frame.depth -= 1
            else:
                self.pop(i)
        elif (
            text.startswith("<<", i)
            and not text.startswith("<<<", i)
            and (i == 0 or text[i - 1] != "<")
            and not any(f.arith for f in self.stack)
        ):
            m = HEREDOC_START.match(text, i)
            if m:
                self.heredocs.append((m.group(3), bool(m.group(2))))
                return m.end()
        elif ch == "\n" and self.heredocs:
            return self.skip_heredocs(i)
        return i + 1

    def skip_heredocs(self, newline: int) -> int:
        """Handle the heredocs started on the line ending at `newline`."""
        text = self.text
        line_start = text.rfind("\n", 0, newline) + 1
        # Quoted words on the line (a PR title, a SQL comment) are data, not the
        # body's consumer: only the unquoted text can name a shell.
        strings = [
            (s, e, " Q ") for s, e in self.quoted if line_start <= s and e <= newline
        ]
        line = without(text, strings, line_start, newline)
        # A line ending in `|` continues the pipeline after the body: its
        # consumer (maybe a shell) is out of sight, so treat the body as code.
        shell_bound = bool(SHELL_WORD.search(line)) or line.rstrip().endswith("|")
        pos, body_end = newline + 1, newline + 1
        for delim, quoted in self.heredocs:
            term = self.find_line(pos, delim)
            if term is None:
                break  # no terminator: not a heredoc we can trust, keep every line
            start, end = term
            if shell_bound:
                self.drop.append((start, end, ""))
            else:
                self.drop.append((pos, end, ""))
                if not quoted:  # an unquoted delimiter still expands $(...) and `...`
                    self.expand.append((pos, start))
            pos = body_end = min(end + 1, len(text))
        self.heredocs = []
        return newline + 1 if shell_bound else body_end

    def find_line(self, pos: int, word: str) -> tuple[int, int] | None:
        """The span of the first line at or after `pos` that is exactly `word`."""
        while pos <= len(self.text):
            end = self.text.find("\n", pos)
            end = len(self.text) if end < 0 else end
            if self.text[pos:end].strip() == word:
                return pos, end
            if end == len(self.text):
                return None
            pos = end + 1
        return None


def ansi_c(body: str) -> str:
    """The body of a $'...' string as the equivalent single-quoted word."""
    value = ANSI_C_ESCAPE.sub(
        lambda m: ANSI_C_CHARS.get(m.group(1), "\\" + m.group(1)), body
    )
    return shlex.quote(value)


def without(text: str, drops: list[tuple[int, int, str]], lo: int, hi: int) -> str:
    """text[lo:hi] with every dropped span replaced by its replacement text."""
    out: list[str] = []
    pos = lo
    for start, end, replacement in sorted(drops):
        if end <= pos or start >= hi:
            continue
        out.append(text[pos : max(start, pos)])
        out.append(replacement)
        pos = max(pos, min(end, hi))
    out.append(text[pos:hi])
    return "".join(out)


def code_only(scan: Scan) -> str:
    """The command text with quoted strings replaced by Q, drops removed."""
    spans = sorted(
        [(s, e, "drop") for s, e, _ in scan.drop]
        + [(s, e, "Q") for s, e in scan.quoted]
    )
    out: list[str] = []
    pos = 0
    for start, end, kind in spans:
        if start < pos:
            continue  # nested inside a span already handled
        out.append(scan.text[pos:start])
        out.append(" Q " if kind == "Q" else "")
        pos = end
    out.append(scan.text[pos:])
    return "".join(out)


@dataclass
class Command:
    args: list[str] = field(default_factory=lambda: [])
    herestrings: list[str] = field(default_factory=lambda: [])


def commands(text: str) -> Iterator[Command]:
    """Yield each simple command; redirect targets dropped, here-strings kept."""
    lexer = shlex.shlex(text, posix=True, punctuation_chars=PUNCTUATION)
    lexer.whitespace = " \t\r"
    lexer.whitespace_split = True
    lexer.commenters = ""
    cmd, pending = Command(), ""
    for token in lexer:
        if pending:
            if pending == "<<<":
                cmd.herestrings.append(token)
            pending = ""
        elif token and set(token) <= set(PUNCTUATION):
            if set(token) & set("()|;`\n") or set(token) == {"&"}:
                if cmd.args:
                    yield cmd
                cmd = Command()
            else:
                pending = token  # a redirection: its target is not an argument
                if cmd.args and cmd.args[-1].isdigit():
                    cmd.args.pop()  # the fd number of `2>&1` / `2>/dev/null`
        else:
            cmd.args.append(token)
    if cmd.args:
        yield cmd


def peel(tokens: list[str]) -> list[str]:
    """Remove leading keywords, VAR=value assignments and wrapper commands."""
    while tokens:
        head = PurePosixPath(tokens[0]).name
        if tokens[0] in KEYWORDS or re.fullmatch(r"[A-Za-z_]\w*=.*", tokens[0]):
            tokens = tokens[1:]
        elif head == "rtk":
            tokens = tokens[2:] if tokens[1:2] == ["proxy"] else tokens[1:]
        elif head == "env" and any(t in ("-S", "--split-string") for t in tokens[1:]):
            j = next(k for k, t in enumerate(tokens) if t in ("-S", "--split-string"))
            tokens = (
                shlex.split(tokens[j + 1]) + tokens[j + 2 :]
                if j + 1 < len(tokens)
                else []
            )
        elif head in WRAPPERS:
            i = 1
            while i < len(tokens) and (
                tokens[i].startswith("-") or (head == "env" and "=" in tokens[i])
            ):
                i += 2 if tokens[i] in WRAPPERS[head] else 1
            if head in TAKES_DURATION and i < len(tokens):
                i += 1
            tokens = tokens[i:]
        else:
            break
    return tokens


def short_flags(token: str) -> str:
    """The letters of a single-dash option cluster (`-fdx` -> `fdx`), else ''."""
    return token[1:] if re.fullmatch(r"-[A-Za-z]+", token) else ""


def has_flag(args: list[str], letter: str, long: str) -> bool:
    return any(
        a == long or a.startswith(long + "=") or letter in short_flags(a) for a in args
    )


def positionals(args: list[str], with_value: set[str]) -> list[str]:
    """Non-option arguments, skipping the values of options that take one."""
    out: list[str] = []
    skip = False
    for arg in args:
        if skip:
            skip = False
        elif arg in with_value:
            skip = True
        elif not arg.startswith("-"):
            out.append(arg)
    return out


def current_branch(cwd: str, git_opts: list[str]) -> str:
    """The branch checked out in `cwd` (honoring git -C), or '' if unknown."""
    try:
        result = subprocess.run(
            ["git", *git_opts, "branch", "--show-current"],
            cwd=cwd or None,
            capture_output=True,
            text=True,
            timeout=3,
            check=False,
        )
    except (OSError, subprocess.SubprocessError):
        return ""
    return result.stdout.strip() if result.returncode == 0 else ""


def check_push(args: list[str], cwd: str, git_opts: list[str]) -> None:
    refspecs = positionals(args, PUSH_OPTS_WITH_VALUE)[1:]
    force = any(r.startswith("+") for r in refspecs) or any(
        a in ("--force", "--force-with-lease")
        or a.startswith("--force-with-lease=")
        or "f" in short_flags(a)
        for a in args
    )
    delete = any(a in ("--delete", "-d") for a in args)
    if "--mirror" in args:
        raise Blocked("git push --mirror rewrites and deletes remote branches")
    if force and any(a in ("--all", "--branches") for a in args):
        raise Blocked("force-push of every branch (--all/--branches)")
    if not (force or delete or any(r.startswith(":") for r in refspecs)):
        return
    for ref in refspecs or ["HEAD"]:
        src, _, dst = ref.lstrip("+").rpartition(":")
        dst = dst.removeprefix("refs/heads/")
        if dst in ("HEAD", "@"):
            dst = current_branch(cwd, git_opts) or "(unknown branch)"
        if dst in PROTECTED_BRANCHES or dst == "(unknown branch)" or "*" in dst:
            if force or delete or (":" in ref and not src):
                raise Blocked(f"force-push or delete of {dst}")


def check_git(args: list[str], cwd: str) -> None:
    git_opts: list[str] = []
    i = 0
    while i < len(args) and args[i].startswith("-"):
        step = 2 if args[i] in GIT_OPTS_WITH_VALUE else 1
        opts = args[i : i + step]
        if opts[0] == "-C" and len(opts) == 2:
            opts = ["-C", expand_path(opts[1], cwd)]  # no shell expands its ~ for git
        git_opts += opts
        i += step
    if i >= len(args):
        return
    sub, rest = args[i], args[i + 1 :]
    if sub == "push":
        check_push(rest, cwd, git_opts)
    elif sub == "reset" and "--hard" in rest:
        raise Blocked("git reset --hard discards uncommitted work")
    elif sub == "checkout" and discards_worktree(rest, cwd, git_opts):
        raise Blocked("git checkout of paths (or -f) discards uncommitted work")
    elif sub == "switch" and (
        "--discard-changes" in rest or has_flag(rest, "f", "--force")
    ):
        raise Blocked("git switch --discard-changes / -f discards uncommitted work")
    elif sub == "restore" and (
        has_flag(rest, "W", "--worktree") or not has_flag(rest, "S", "--staged")
    ):
        raise Blocked("git restore of the working tree discards uncommitted work")
    elif sub == "clean" and has_flag(rest, "f", "--force"):
        raise Blocked("git clean -f deletes untracked files")


def discards_worktree(args: list[str], cwd: str, git_opts: list[str]) -> bool:
    """Whether `git checkout ARGS` overwrites working-tree files."""
    if any(a in ("--", ".") or a.startswith("./") for a in args):
        return True
    if has_flag(args, "f", "--force"):
        return True
    base = Path(cwd)
    for i, opt in enumerate(git_opts[:-1]):
        if opt == "-C":
            base = base / git_opts[i + 1]
    names = positionals(args, {"-b", "-B", "--orphan", "--conflict"})
    return any((base / name).exists() for name in names)


def expand_path(target: str, cwd: str) -> str:
    """Resolve ~, $HOME, ${HOME...}, $USER, a trailing /* or /.*, and cwd."""
    path = re.sub(r"\$\{HOME(?::[-?=+][^}]*)?\}|\$HOME\b", HOME, target)
    path = re.sub(r"\$\{USER\}|\$USER\b", getpass.getuser(), path)
    if path.startswith("~"):
        path = os.path.expanduser(path)  # ~ and ~user
    path = path.rstrip("/") or "/"
    path = re.sub(r"/\.?\*$", "", path) if path not in ("/*", "/.*") else "/"
    if path in ("*", ".*", ""):
        path = "."
    return os.path.normpath(path if path.startswith("/") else os.path.join(cwd, path))


def wipes_home_or_root(path: str) -> bool:
    """Whether `path` is /, $HOME or an ancestor of $HOME (APFS is case-insensitive)."""
    path, home = path.lower(), HOME.lower()
    return path == "/" or path == home or home.startswith(path + "/")


def check_rm(args: list[str], cwd: str, relative: bool = True) -> None:
    if not any(a == "--recursive" or set(short_flags(a)) & {"r", "R"} for a in args):
        return
    for target in positionals(args, set()):
        if not relative and not re.match(r"[/~$]", target):
            continue  # the backstop has no cwd tracking: absolute/home targets only
        if wipes_home_or_root(expand_path(target, cwd)):
            raise Blocked("recursive rm of /, ~, $HOME or an ancestor of $HOME")


def check_shell_args(args: list[str], cwd: str, depth: int) -> None:
    """Evaluate the command string a shell runs with -c (its first operand)."""
    i, has_c = 0, False
    while i < len(args):
        arg = args[i]
        if arg == "--":
            i += 1
            break
        if arg in SHELL_OPTS_WITH_VALUE:
            i += 2
        elif arg[:1] in "-+" and len(arg) > 1:
            has_c = has_c or "c" in short_flags(arg)
            i += 1
        else:
            break
    if has_c and i < len(args):
        evaluate(args[i], cwd, depth + 1)


def backstop(code: str, cwd: str) -> None:
    """Re-check the code-only text word by word; see the module docstring."""
    for segment in re.split(r"[;&|()\n`]", code):
        words = segment.split()
        names = [PurePosixPath(w).name for w in words]
        if "git" in names:
            rest = words[names.index("git") + 1 :]
            push_targets = {
                r.lstrip("+").rpartition(":")[2].removeprefix("refs/heads/")
                for r in rest
            }
            if "reset" in rest and "--hard" in rest:
                raise Blocked("git reset --hard discards uncommitted work (backstop)")
            if "push" in rest and (
                "--mirror" in rest
                or (
                    has_flag(rest, "f", "--force") and push_targets & PROTECTED_BRANCHES
                )
            ):
                raise Blocked("force-push to main/master (backstop)")
            if "clean" in rest and has_flag(rest, "f", "--force"):
                raise Blocked("git clean -f deletes untracked files (backstop)")
            after = rest[rest.index("checkout") + 1 :] if "checkout" in rest else []
            if "--" in after or "." in after:
                raise Blocked(
                    "git checkout . / -- <path> discards uncommitted work (backstop)"
                )
        if "rm" in names:
            check_rm(words[names.index("rm") + 1 :], cwd, relative=False)


def evaluate(text: str, cwd: str, depth: int = 0) -> None:
    """Raise Blocked if any command in `text` is destructive."""
    if depth > MAX_DEPTH:
        raise Blocked("command nesting too deep to inspect")
    text = text.replace("\\\n", "")
    scan = Scan(text)
    for start, end in scan.subst:
        evaluate(without(text, scan.drop, start, end), cwd, depth + 1)
    for start, end in scan.expand:
        body = Scan('"' + text[start:end].replace('"', '\\"') + '"')
        for s_start, s_end in body.subst:
            evaluate(body.text[s_start:s_end], cwd, depth + 1)
    for cmd in commands(without(text, scan.drop, 0, len(text))):
        cwd = check_command(cmd, cwd, depth)
    backstop(code_only(scan), cwd)


def check_command(cmd: Command, cwd: str, depth: int) -> str:
    """Check one simple command; return the cwd after it (for `cd`)."""
    tokens = peel(cmd.args)
    if not tokens:
        return cwd
    program, args = PurePosixPath(tokens[0]).name, tokens[1:]
    if program in ("cd", "pushd"):
        dirs = [a for a in args if a == "-" or not a.startswith("-")]
        if not dirs:
            return HOME if program == "cd" else cwd
        return cwd if dirs[0] == "-" else expand_path(dirs[0], cwd)
    if program in SHELLS or program == "eval":
        for herestring in cmd.herestrings:
            evaluate(herestring, cwd, depth + 1)
    if program == "eval":
        evaluate(" ".join(args), cwd, depth + 1)
    elif program in SHELLS:
        check_shell_args(args, cwd, depth)
    elif program == "git":
        check_git(args, cwd)
    elif program == "rm":
        check_rm(args, cwd)
    return cwd


def parse_payload(raw: object) -> tuple[str, str]:
    """The command and working directory from a PreToolUse hook payload."""
    if not isinstance(raw, dict):
        raise ValueError("payload is not a JSON object")
    payload = cast("dict[str, object]", raw)
    tool_input = payload.get("tool_input")
    fields = (
        cast("dict[str, object]", tool_input) if isinstance(tool_input, dict) else {}
    )
    command = fields.get("command")
    cwd = payload.get("cwd")
    return (
        command if isinstance(command, str) else "",
        cwd if isinstance(cwd, str) and cwd else str(Path.cwd()),
    )


def main() -> int:
    try:
        command, cwd = parse_payload(cast(object, json.load(sys.stdin)))
        evaluate(command, cwd)
    except Blocked as reason:
        print(f"BLOCKED: {reason}", file=sys.stderr)
        print(
            "Ask the user to run it themselves if it is really intended.",
            file=sys.stderr,
        )
        return 2
    except Exception as error:  # fail closed: an unreadable command is not a safe one
        print(
            f"BLOCKED: guard could not inspect the command ({error})", file=sys.stderr
        )
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main())
