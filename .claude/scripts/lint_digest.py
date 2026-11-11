"""Summarize a repo's lint configs into the session context (SessionStart hook).

Claude Code adds a SessionStart hook's stdout to the session context. This
prints the parts of a repo's lint configuration a model cannot guess, so code
is written to pass them instead of being fixed after the edit-lint hook or the
fast checks flag it:
  - limits: line length, function size, complexity thresholds
  - project-specific bans: forbidigo patterns, depguard denies, ruff
    banned-api entries, semgrep rules (each with its message)
  - the ruff select/ignore set and the pyright/basedpyright checking mode
  - a pointer to each eslint config (JS code, which this cannot evaluate)
Stock linter catalogs are left out: they cost tokens and change nothing.

Configs are found with `git ls-files` (tracked plus untracked, ignored files
excluded) at any depth under the repo root. YAML is converted with `yq -o
json`; without yq the YAML configs are skipped with a note. Prints nothing
outside git or when no config exists. Never fails the session: an error is
reported on stderr (shown to the user, not Claude) and the exit stays 0.
"""

from __future__ import annotations

import json
import posixpath
import re
import subprocess
import sys
import tomllib
from pathlib import Path, PurePosixPath
from typing import cast

# Output cap: SessionStart output is paid for on every turn of the session.
MAX_LINES = 80
MAX_SEMGREP_RULES = 25
# depguard rules listed per config; the rest are counted. Layered repos write
# one rule per tier per service (70 on one repo), which would bury the rest.
MAX_DEPGUARD_RULES = 10
GOLANGCI = {".golangci.yml", ".golangci.yaml", ".golangci.toml", ".golangci.json"}
RUFF = {"pyproject.toml", "ruff.toml", ".ruff.toml"}
ESLINT = {
    "eslint.config.js",
    "eslint.config.mjs",
    "eslint.config.cjs",
    "eslint.config.ts",
    "eslint.config.mts",
    "eslint.config.cts",
    ".eslintrc",
    ".eslintrc.js",
    ".eslintrc.cjs",
    ".eslintrc.json",
    ".eslintrc.yml",
    ".eslintrc.yaml",
}
SEMGREP = {".semgrep.yml", ".semgrep.yaml"}
# Directory names that hold vendored rule packs: counted, never listed or
# parsed (one yq call per file cost seconds on a repo with 300+ such rules).
VENDORED = {"community", "vendor", "vendored", "third_party"}
RULE_ID = re.compile(r"^\s*-\s*id:", re.MULTILINE)
# golangci-lint settings that are thresholds, by linter.
GO_LIMITS: dict[str, tuple[str, ...]] = {
    "lll": ("line-length",),
    "funlen": ("lines", "statements"),
    "gocyclo": ("min-complexity",),
    "cyclop": ("max-complexity",),
    "gocognit": ("min-complexity",),
    "nestif": ("min-complexity",),
    "nakedret": ("max-func-lines",),
    "dupl": ("threshold",),
}
# ruff thresholds: (plugin section, setting).
RUFF_LIMITS = (
    ("mccabe", "max-complexity"),
    ("pylint", "max-args"),
    ("pylint", "max-branches"),
    ("pylint", "max-statements"),
    ("pylint", "max-returns"),
)

# One config's digest: a one-line summary and indented detail lines.
type Summary = tuple[str, list[str]]


class YamlUnavailableError(Exception):
    """Raised when yq is missing, so YAML configs cannot be read."""


def get(obj: object, *keys: str) -> object:
    """obj[k1][k2]... through nested JSON objects; None where a key is missing."""
    for key in keys:
        if not isinstance(obj, dict):
            return None
        obj = cast("dict[str, object]", obj).get(key)
    return obj


def as_dict(obj: object) -> dict[str, object]:
    """obj when it is a JSON object, else an empty one."""
    return cast("dict[str, object]", obj) if isinstance(obj, dict) else {}


def as_list(obj: object) -> list[object]:
    """obj when it is a JSON array, else an empty one."""
    return cast("list[object]", obj) if isinstance(obj, list) else []


def words(obj: object) -> str:
    """A JSON array of scalars as `a, b, c`; a scalar as itself."""
    if isinstance(obj, list):
        return ", ".join(str(v) for v in as_list(obj))
    return str(obj)


def ban(kind: str, target: object, why: object) -> str:
    """One detail line: `  - <kind> `<target>`: <why>` (why omitted if empty)."""
    return f"  - {kind} `{target}`" + (f": {why}" if why else "")


def load(path: Path) -> object:
    """A config file's content as JSON-like data (YAML via yq, TOML, JSON)."""
    if path.suffix == ".toml":
        return tomllib.loads(path.read_text())
    if path.suffix == ".json":
        return cast("object", json.loads(path.read_text()))
    try:
        out = subprocess.run(
            ["yq", "-o", "json", ".", str(path)],
            capture_output=True,
            text=True,
            timeout=5,
            check=True,
        ).stdout
    except FileNotFoundError as error:
        raise YamlUnavailableError from error
    return cast("object", json.loads(out or "null"))


def golangci(cfg: object) -> Summary:
    """Enabled linters, thresholds, and forbidigo / depguard bans (v1 or v2)."""
    linters = as_dict(get(cfg, "linters"))
    settings = as_dict(linters.get("settings") or get(cfg, "linters-settings"))
    head: list[str] = []
    if "default" in linters:
        head.append(f"default {linters['default']}")
    if linters.get("enable"):
        head.append(f"enable {words(linters['enable'])}")
    limits = [
        f"{name} {key} {value}"
        for name, keys in GO_LIMITS.items()
        for key in keys
        if (value := get(settings, name, key)) is not None
    ]
    if limits:
        head.append("limits: " + ", ".join(limits))
    details: list[str] = []
    for entry in as_list(get(settings, "forbidigo", "forbid")):
        pattern = (
            entry
            if isinstance(entry, str)
            else get(entry, "pattern") or get(entry, "p")
        )
        details.append(ban("forbidigo bans", pattern, get(entry, "msg")))
    rules = as_dict(get(settings, "depguard", "rules"))
    for name, rule in list(rules.items())[:MAX_DEPGUARD_RULES]:
        if line := depguard(name, as_list(get(rule, "deny"))):
            details.append(line)
    if len(rules) > MAX_DEPGUARD_RULES:
        details.append(
            f"  - … {len(rules) - MAX_DEPGUARD_RULES} more depguard rules;"
            " grep the config before adding an import across packages"
        )
    return "; ".join(head), details


def depguard(name: str, denies: list[object]) -> str | None:
    """One depguard rule's denies as one line: the shared package prefix once,
    then each package's remainder; the reason only when every deny shares it.
    """
    pkgs = [str(get(d, "pkg")) for d in denies if get(d, "pkg")]
    if not pkgs:
        return None
    descs = {str(get(d, "desc") or "") for d in denies}
    why = descs.pop() if len(descs) == 1 else "reasons per package in the config"
    if len(pkgs) == 1:
        return ban(f"depguard[{name}] denies", pkgs[0], why)
    prefix = posixpath.commonpath(pkgs)
    rest = ", ".join(p[len(prefix) :].lstrip("/") or p for p in pkgs)
    target = f"{prefix}/{{{rest}}}" if prefix else rest
    return ban(f"depguard[{name}] denies", target, why)


def ruff(cfg: dict[str, object]) -> Summary:
    """ruff's line length, rule selection, thresholds, and banned APIs."""
    lint = as_dict(cfg.get("lint"))
    head: list[str] = []
    if "line-length" in cfg:
        head.append(f"line-length {cfg['line-length']}")
    for key in ("select", "extend-select", "ignore"):
        if value := lint.get(key, cfg.get(key)):
            head.append(f"{key} {words(value)}")
    if convention := get(lint, "pydocstyle", "convention"):
        head.append(f"docstrings {convention}")
    head += [
        f"{plugin} {key} {value}"
        for plugin, key in RUFF_LIMITS
        if (value := get(lint, plugin, key)) is not None
    ]
    banned = as_dict(get(lint, "flake8-tidy-imports", "banned-api"))
    details = [
        ban("banned import", mod, get(spec, "msg")) for mod, spec in banned.items()
    ]
    return "; ".join(head), details


def semgrep(cfg: object) -> Summary:
    """Each semgrep rule as `id: first line of its message`, capped."""
    rules = as_list(get(cfg, "rules"))
    details: list[str] = []
    for rule in rules[:MAX_SEMGREP_RULES]:
        message = str(get(rule, "message") or "").strip().splitlines()
        details.append(
            f"  - {get(rule, 'id')}" + (f": {message[0]}" if message else "")
        )
    if len(rules) > MAX_SEMGREP_RULES:
        details.append(f"  - … {len(rules) - MAX_SEMGREP_RULES} more rules")
    return f"{len(rules)} rules", details


def summaries(name: str, path: Path) -> list[tuple[str, Summary]]:
    """(tool, summary) for each tool one config file configures."""
    if name in ESLINT:
        return [("eslint", ("JS config: read it before writing JS/TS under it", []))]
    data = load(path)
    if name in GOLANGCI:
        return [("golangci-lint", golangci(data))]
    if name in SEMGREP or name.endswith((".yml", ".yaml")):
        return [("semgrep", semgrep(data))]
    if name == "pyrightconfig.json":
        mode = get(data, "typeCheckingMode")
        return [("pyright", (f"typeCheckingMode {mode}", []))] if mode else []
    tool = as_dict(get(data, "tool")) if name == "pyproject.toml" else {"ruff": data}
    out: list[tuple[str, Summary]] = []
    if "ruff" in tool:
        out.append(("ruff", ruff(as_dict(tool["ruff"]))))
    for checker in ("basedpyright", "pyright"):
        if mode := get(tool, checker, "typeCheckingMode"):
            out.append((checker, (f"typeCheckingMode {mode}", [])))
    return out


def section(rel: str, path: Path) -> list[str]:
    """The digest lines for one config file; none when it holds no lint config
    or nothing worth saying (e.g. a [tool.ruff] that only extends another).
    """
    lines: list[str] = []
    for tool, (head, details) in summaries(path.name, path):
        if not head and not details:
            continue
        lines.append(f"- {rel} ({tool})" + (f": {head}" if head else ""))
        lines += details
    return lines


def is_config(rel: str) -> bool:
    """Whether a repo-relative path names a lint config this digest reads."""
    path = PurePosixPath(rel)
    if (
        path.name in GOLANGCI | RUFF | ESLINT | SEMGREP
        or path.name == "pyrightconfig.json"
    ):
        return True
    return ".semgrep" in path.parts[:-1] and path.suffix in {".yml", ".yaml"}


def is_vendored(rel: str) -> bool:
    """Whether a semgrep config sits in a vendored rule pack directory."""
    return bool(VENDORED & set(PurePosixPath(rel).parts[:-1]))


def vendored_line(root: Path, rels: list[str]) -> list[str]:
    """One line counting the rules in vendored semgrep packs (ids omitted)."""
    if not rels:
        return []
    count = sum(len(RULE_ID.findall((root / rel).read_text())) for rel in rels)
    return [
        f"- semgrep: {count} vendored rules in {len(rels)} files"
        " (stock packs, ids omitted; semgrep enforces them)"
    ]


def repo_files(cwd: str) -> tuple[Path, list[str]] | None:
    """The repo root above cwd and its non-ignored files; None outside git."""

    def git(*args: str) -> str:
        return subprocess.run(
            ["git", "-C", cwd, *args],
            capture_output=True,
            text=True,
            timeout=10,
            check=True,
        ).stdout

    try:
        root = Path(git("rev-parse", "--show-toplevel").strip())
        files = git("-C", str(root), "ls-files", "-co", "--exclude-standard")
    except (OSError, subprocess.SubprocessError):
        return None
    return root, files.splitlines()


def digest(cwd: str) -> str:
    """The full digest text for the repo containing cwd ('' when none)."""
    found = repo_files(cwd)
    if found is None:
        return ""
    root, files = found
    lines: list[str] = []
    yaml_skipped = False
    configs = sorted(f for f in files if is_config(f))
    vendored = [f for f in configs if is_vendored(f)]
    for rel in (f for f in configs if not is_vendored(f)):
        try:
            lines += section(rel, root / rel)
        except YamlUnavailableError:
            yaml_skipped = True
    lines += vendored_line(root, vendored)
    if yaml_skipped:
        lines.append("- yq not installed: YAML lint configs not summarized; read them")
    if not lines:
        return ""
    if len(lines) > MAX_LINES:
        more = len(lines) - MAX_LINES
        lines = [*lines[:MAX_LINES], f"- … {more} more lines; read the configs"]
    header = [
        f"## Lint digest: {root.name}",
        "Write code that passes these up front; edit-lint runs the project linter",
        "after every edit. Fix findings, never suppress them.",
    ]
    return "\n".join(header + lines) + "\n"


def main() -> int:
    """Read the SessionStart payload on stdin and print the digest."""
    try:
        payload = as_dict(cast("object", json.load(sys.stdin)))
        cwd = payload.get("cwd")
        cwd = cwd if isinstance(cwd, str) and cwd else str(Path.cwd())
        sys.stdout.write(digest(cwd))
    except Exception as error:  # advisory output: never block a session start
        print(f"lint digest skipped: {error}", file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
