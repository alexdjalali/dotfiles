#!/usr/bin/env bash
# shellcheck disable=SC2031  # $T is set per test by run_test (tests/lib/assert.sh)
# Tests for .claude/scripts/guard-bash.sh, the Claude Code PreToolUse hook that
# blocks destructive shell commands.
#
# The destructive commands below exist only as data in this file. The live
# guard scans Bash command lines, so run this file (`just test`); never paste
# the rows into a shell.
set -uo pipefail
# shellcheck source=../lib/assert.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/assert.sh"

GUARD="$REPO_ROOT/.claude/scripts/guard-bash.sh"

# Exit status of the guard for one command string, fed as the hook's JSON. The
# cwd is the test's empty temp dir, so no row depends on where the suite runs.
guard_status() {
  jq -cn --arg c "$1" --arg d "$T" '{cwd: $d, tool_input: {command: $c}}' | bash "$GUARD" >/dev/null 2>&1
  echo $?
}

# The $HOME rows are deliberately literal: the guard must catch them unexpanded.
# shellcheck disable=SC2016
MUST_BLOCK=(
  'git push --force origin main'
  'git push -f origin main'
  'git push origin main --force'
  'git push --force-with-lease origin main'
  'git push --force-with-lease=main:abc123 origin main'
  'git push origin +main'
  'git push origin HEAD:main --force'
  'git push -f origin master'
  'git -C repo push -f origin main'
  'bash -c "git push -f origin main"'
  'rm -rf /'
  'rm -rf /*'
  'rm -fr /'
  'rm -r -f ~'
  'rm -rf ~'
  'rm -rf ~/'
  'rm -rf "$HOME"'
  'rm -rf $HOME/'
  'rm -rf ${HOME}'
  "rm -rf $HOME"
  'sudo rm -rf /'
  'cd /tmp && rm -rf ~'
  'echo ok; rm -rf ~'
  'git reset --hard'
  'git reset --hard HEAD~1'
  'git checkout .'
  'git checkout -- .'
  'git checkout -- src/a.txt'
  'git checkout main -- src/a.txt'
  'git restore .'
  'git restore src/a.txt'
  'git restore --worktree src/a.txt'
  'git restore --staged --worktree src/a.txt'
  'git clean -f'
  'git clean -fdx'
  'git clean -fn'
  $'bash <<\'EOF\'\nrm -rf ~\nEOF'
  $'cd /tmp && sh <<EOF\ngit reset --hard\nEOF'
  'for d in a b; do git -C "$d" reset --hard; done'
  'if true; then rm -rf ~; fi'
  'if git reset --hard; then :; fi'
  '! git reset --hard'
  $'git reset \\\n  --hard'
  $'git push \\\n  --force origin main'
  'git reset --hard>/dev/null'
  'rtk proxy git push -f origin main'
  'rtk git reset --hard'
  '/usr/bin/git reset --hard'
  '/usr/bin/rm -rf ~'
  '/bin/bash -c "git reset --hard"'
  'bash -ec "git reset --hard"'
  'sudo -u root rm -rf /'
  'env -i rm -rf ~'
  'eval git reset --hard'
  'timeout 10 git reset --hard'
  'xargs git reset --hard'
  'echo "$(rm -rf ~)"'
  'echo `git reset --hard`'
  'rm -rf /Users'
  $'cat <<< hello\ngit reset --hard'
  $'cat > f <<END-DATA\nx\nEND-DATA\ngit reset --hard'
  $'/bin/bash <<\'EOF\'\nrm -rf ~\nEOF'
  $'bash<<EOF\nrm -rf ~\nEOF'
  $'npm test  # run tests\ngit push --force origin main'
  $'cd repo  # go\ngit reset --hard'
  'echo ${#arr[@]}; git reset --hard'
  $'cat <<\'EOF\' | bash\ngit reset --hard\nEOF'
  $'bash -c "$(cat <<\'EOF\'\ngit reset --hard\nEOF\n)"'
  $'eval "$(cat <<\'EOF\'\nrm -rf ~\nEOF\n)"'
  $'sudo -u root bash <<EOF\nrm -rf ~\nEOF'
  $'env -i bash <<EOF\nrm -rf ~\nEOF'
  $'timeout 10 bash <<EOF\nrm -rf ~\nEOF'
  "bash <<< 'git reset --hard'"
  'diff <(git reset --hard) x'
  'cat <(rm -rf ~)'
  'echo x > "$(rm -rf ~)"'
  "bash -o pipefail -c 'git reset --hard'"
  "bash -O extglob -c 'rm -rf ~'"
  'git push --mirror origin'
  'git push origin :main'
  'git push origin --delete main'
  'rm -rf ~/.*'
  'rm -rf $HOME/..'
  'rm -rf "${HOME:?}/"'
  'rm -rf /Users/$USER'
  'cd ~ && rm -rf *'
  'cd && rm -rf ./*'
  $'grep -c "<<EOF" install.sh\ngit reset --hard\ncat > f <<EOF\nx\nEOF'
  'git --git-dir .git reset --hard'
  'gtimeout 5 git reset --hard'
  'caffeinate git reset --hard'
  "dash -c 'git reset --hard'"
  $'cat > notes.md <<EOF\n- `rm -rf /` wipes the disk\nEOF\necho done'
  $'gh pr create --body "$(cat <<EOF\n- now blocks `git reset --hard`\nEOF\n)"'
  'git switch --discard-changes main'
  'git switch -f main'
  'git checkout -f main'
  $'git re\\\nset --hard'
  'echo a\ #x; git reset --hard'
  "bash -c -e 'git reset --hard'"
  "bash -c -- 'git reset --hard'"
  "env -S 'git reset --hard'"
  "fish -c 'rm -rf ~'"
  $'source /dev/stdin <<\'EOF\'\nrm -rf ~\nEOF'
  $'$SHELL <<\'EOF\'\nrm -rf ~\nEOF'
  $'cat <<\'EOF\' |\nrm -rf ~\nEOF\nbash'
  $'echo $((1<<2))\nrm -rf ~\n2'
  $'echo "$((1<<2))"\nrm -rf ~\n2'
  $'bash -c $\'cd /tmp\\ngit reset --hard\''
  $'eval $\'rm -rf ~\''
  "git push -f origin 'refs/heads/*:refs/heads/*'"
  'pushd ~ && rm -rf *'
  'cd -- ~ && rm -rf *'
  'rm -rf ~/*/'
  'rm -rf /*/'
  "rm -rf ~${USER}"
  "rm -rf $(printf '%s' "$HOME" | tr '[:upper:]' '[:lower:]')"
  # git hook bypasses (guard_rules.json, generated from the rule catalog)
  'git commit --no-verify -m x'
  'git am --no-verify x.patch'
  'git commit -n -m x'
  'git commit -m x -n'
  'git push --no-verify'
  'git merge --no-verify x'
  'git rebase --no-verify main'
  'LEFTHOOK=0 git commit -m x'
  'env LEFTHOOK=0 git push'
  'LEFTHOOK=false git merge x'
  "bash -c 'git commit --no-verify -m x'"
  # git accepts any unambiguous prefix of a long option
  'git commit --no-veri -m x'
  'git push --no-verif'
  # Structural checks honor abbreviations too (git accepts them).
  'git reset --har'
  'git push --mirr origin'
  'git push origin --del main'
  'git push --forc origin main'
  'git switch --discard main'
  # --source is not --staged: without --staged, restore writes the worktree.
  'git restore --source=HEAD src/a.txt'
  # cwd is not a repo, so the branch a bare push targets is unknown.
  'git push -f'
  # `:` pushes every matching branch; heads/main is main.
  'git push -f origin :'
  'git push -f origin heads/main'
  'mise exec -- git push -f origin heads/main'
  'mise exec -- git push -f origin :'
  'git push origin +:'
  # git behind a wrapper peel does not know (mise exec --) gets every git
  # rule, catalog bans included, as if run directly.
  'mise exec -- git push -f origin refs/heads/*:refs/heads/*'
  'mise exec -- git push origin :main'
  'mise exec -- git push -f'
  'mise exec -- git push origin +:'
  'mise exec -- git push -f origin "main"'
  'mise exec -- git switch --discard-changes main'
  'mise exec -- git checkout -f main'
  'mise exec -- git restore src/a.txt'
  'mise exec -- git commit --no-verify -m x'
  'mise exec -- git -c core.hooksPath=/dev/null commit -m x'
  'LEFTHOOK=0 mise exec -- git commit -m x'
  'mise exec -- git push -f --all origin'
  'mise exec -- git push -f --branch origin'
  'mise exec -- git push --force-with-lease --all origin'
  'mise exec -- git push origin +main'
  'mise exec -- git push -o ci.skip origin +main'
  # an exported ban reaches every later command; a wrapper passes its env on
  'export LEFTHOOK=0; git commit -m x'
  'declare -x LEFTHOOK=0'
  'sudo LEFTHOOK=0 git commit -m x'
  # pointing core.hooksPath elsewhere (or unsetting it) runs no hooks at all
  'git -c core.hooksPath=/dev/null commit -m x'
  'git -c core.hookspath=/dev/null push'
  'X=/dev/null git --config-env=core.hooksPath=X commit -m x'
  'GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=core.hooksPath GIT_CONFIG_VALUE_0=/dev/null git commit -m x'
  'git config core.hooksPath /dev/null'
  'git config --global core.hooksPath /dev/null'
  'git config set core.hooksPath /dev/null'
  'git config --unset core.hooksPath'
)

# Destructive text is allowed only when quoted: an unquoted mention such as
# `echo rm -rf ~` or `echo git push -f origin main` is judged as a command by
# design (git and rm behind a wrapper the parser does not know are judged on
# their own tokens), trading that rare false positive for catching wrappers.
# shellcheck disable=SC2016  # literal $ rows, as the model would type them
MUST_ALLOW=(
  # Wrapped git that is safe unwrapped stays allowed.
  'mise exec -- git push -f origin feature/x'
  'mise exec -- git push --all origin'
  'mise exec -- git restore --staged src/a.txt'
  # A push option is not a refspec, even when it starts with +.
  'git push -o +ci.skip origin main'
  # An unforced matching push only fast-forwards.
  'git push origin :'
  # refs/main is a one-level ref, not the main branch.
  'git push -f origin HEAD:refs/main'
  # An option sharing a prefix with the one a check looks for
  # (--discard-changes).
  'git switch --detach'
  # Prefix matching runs one way: a longer option that merely starts with a
  # banned one is a different option.
  'git merge --no-verify-signatures x'
  'git push --force-if-includes origin main'
  'git switch --force-create x'
  'git status'
  'git commit --no-edit'
  'export FOO=1; git commit -m x'
  'declare LEFTHOOK=0'
  'git config --get core.hooksPath'
  'git config core.hooksPath'
  'git config get core.hooksPath'
  'git config user.name x'
  'git -c color.ui=never commit -m x'
  'git push origin feature/x'
  'git push --force origin feature/x'
  'git push origin main'
  'git push -u origin main'
  'git push --follow-tags origin main'
  'git push origin force-feature-branch'
  'git push origin main-docs'
  'git push --force origin main-docs'
  'git commit -m "never git push -f origin main"'
  'rm -rf ./build'
  'rm -rf /tmp/foo'
  'rm -rf ~/projects/old-thing'
  'rm file.txt'
  'echo "rm -rf ~"'
  'git checkout -b x'
  'git checkout main'
  'git checkout --track origin/foo'
  'git checkout --detach'
  'git checkout --orphan gh-pages'
  'git restore --staged src/a.txt'
  'git clean -n'
  'git reset --soft HEAD~1'
  $'python3 - <<\'PYEOF\'\nprint("never run `git clean -fn` or rm -rf ~ here")\nPYEOF'
  $'cat > notes.md <<\'EOF\'\n- `rm -rf /` wipes the disk\nEOF\necho done'
  'git commit -m "docs: explain why; git reset --hard is blocked"'
  $'git commit -m "subject\n\ngit clean -f is blocked now"'
  'gh pr create --body "Blocks (git reset --hard) now"'
  $'git commit -m "$(cat <<\'EOF\'\nfix: never rm -rf ~\nEOF\n)"'
  'cat <<< "rm -rf ~"'
  'for f in *.tmp; do rm -f "$f"; done'
  'rm -rf "$HOME/projects/old"'
  'git push -f origin feature/x'
  "gh pr create --body 'Blocks \`git reset --hard\` now'"
  "git commit -m 'never run \$(git reset --hard)'"
  'git push origin --delete feature/x'
  $'python3 - <<\'EOF\'\nimport os  # comment\nprint("rm -rf ~")\nEOF'
  'echo "#not a comment"; ls'
  'git log --format="%h (%s)" -5'
  'echo "$(date)-$(whoami)"'
  $'gh pr create --title "fix: guard" --body "$(cat <<\'EOF\'\n## Summary\n- blocks `rm -rf ~` and it\'s tested\nEOF\n)"'
  'for f in $(git ls-files "*.sh"); do shellcheck "$f"; done'
  'docker run --rm -v "$(pwd)":/app node:20 npm ci'
  'cd build && rm -rf *'
  'echo $((1 + 2))'
  'cat <<< "$(git status --short)"'
  $'echo $\'it\\\'s here\''
  'git -C . checkout main'
  'git switch main'
  'git switch -c feature/y'
  $'printf $\'a\\nb\\n\''
  $'gh pr create --title "fix(zsh): guard" --body-file - <<\'EOF\'\ngac doesn\'t stage deletions\nEOF'
  $'gh issue create --title "source maps broken" --body-file - <<\'EOF\'\nit\'s broken\nEOF'
  $'docker exec -i db psql <<\'EOF\'\n-- don\'t touch prod\nSELECT 1;\nEOF'
  # hook-bypass look-alikes
  'git commit -m "mention --no-verify"'
  'git log -n 5'
  'LEFTHOOK=1 git commit -m x'
  'git push -n'
)

# Why this test is important:
#   - With bypassPermissions on, this hook is the only thing standing between a
#     mistaken command and a wiped home directory or a rewritten main branch.
# What it tests:
#   - Every destructive form (force-push variants, recursive rm of / ~ $HOME,
#     reset --hard, checkout discards, worktree restore, clean -f), including
#     compound and nested commands, exits 2.
test_blocks_destructive_commands() {
  local c let_through=()
  for c in "${MUST_BLOCK[@]}"; do
    [[ $(guard_status "$c") == 2 ]] || let_through+=("[$c]")
  done
  assert_eq "" "${let_through[*]-}" "commands the guard let through"
}

# Why this test is important:
#   - An over-broad guard blocks routine git and file work mid-session.
# What it tests:
#   - Everyday commands, and look-alikes (branch names containing main/force,
#     --track/--detach checkouts, staged-only restore, dry-run clean,
#     destructive text inside a commit message, options extending or sharing a
#     prefix with a banned one, wrapped non-forced or feature-branch pushes, a
#     push option starting with +), exit 0.
test_allows_everyday_commands() {
  local c blocked=()
  for c in "${MUST_ALLOW[@]}"; do
    [[ $(guard_status "$c") == 0 ]] || blocked+=("[$c]")
  done
  assert_eq "" "${blocked[*]-}" "commands the guard wrongly blocked"
}

# Guard exit status for a command run from a repo checked out on branch $1.
push_status_on_branch() {
  git -c init.defaultBranch="$1" init -q "$T/repo"
  jq -cn --arg c "$2" --arg d "$T/repo" '{cwd: $d, tool_input: {command: $c}}' |
    bash "$GUARD" >/dev/null 2>&1
  echo $?
}

# Why this test is important:
#   - The most natural force-push forms name no branch, so they push whatever
#     is checked out: on main they rewrite origin/main.
# What it tests:
#   - `git push -f`, `git push --force origin` and `git push origin HEAD --force`
#     are blocked from a repo on main and allowed from a repo on a feature branch,
#     also through `git -C ~/repo` (git gets the `~` unexpanded); the verdict
#     holds with a quoted global option, a quoted assignment or redirection in
#     front, an unknown wrapper, or a later `cd` (each judged on the real
#     tokens and the directory the push runs in).
test_force_push_of_current_branch() {
  local c branch want rc
  for c in 'git push -f' 'git push --force origin' 'git push origin HEAD --force' \
    'git push -o ci.skip --force origin' 'git push -f origin @' 'git push --force origin 2>&1' \
    'git -c "user.name=A B" push -f' 'git push -f && cd /tmp' \
    'GIT_SSH_COMMAND="ssh -i key" git push -f && cd /tmp' \
    '2>/dev/null git -c "a.b=c d" push -f' 'mise exec -- git -c "a.b=c d" push -f'; do
    assert_eq 2 "$(push_status_on_branch main "$c")" "[$c] on main"
    command rm -rf "$T/repo"
    assert_eq 0 "$(push_status_on_branch feature "$c")" "[$c] on feature"
    command rm -rf "$T/repo"
  done
  for branch in main feature; do
    want=0
    [[ $branch == main ]] && want=2
    git -c init.defaultBranch="$branch" init -q "$T/repo"
    jq -cn --arg d "$T" '{cwd: $d, tool_input: {command: "git -C ~/repo push -f"}}' |
      HOME="$T" bash "$GUARD" >/dev/null 2>&1
    rc=$?
    assert_eq "$want" "$rc" "[git -C ~/repo push -f] on $branch"
    command rm -rf "$T/repo"
  done
}

# Why this test is important:
#   - A forced --all/--branches push rewrites every branch, main included, even
#     from a feature branch, where the current-branch check alone passes it.
# What it tests:
#   - `git push -f` with --all, --branches or an abbreviation of either is
#     blocked from a repo on a feature branch.
test_force_push_of_every_branch() {
  local c
  for c in 'git push -f --all origin' 'git push -f --branches origin' \
    'git push -f --al origin' 'git push -f --branch origin'; do
    assert_eq 2 "$(push_status_on_branch feature "$c")" "[$c] on feature"
    command rm -rf "$T/repo"
  done
}

# Why this test is important:
#   - A remote or a `-C` directory named main is not the main branch; reading
#     it as one blocks routine feature-branch pushes.
# What it tests:
#   - From a repo on a feature branch, `git push -f main feature/x` and
#     `git -C main push -f origin feature/x` (main/ a subdirectory) exit 0.
test_push_main_outside_refspec() {
  local c
  for c in 'git push -f main feature/x' 'git -C main push -f origin feature/x'; do
    mkdir -p "$T/repo/main"
    assert_eq 0 "$(push_status_on_branch feature "$c")" "[$c] on feature"
    command rm -rf "$T/repo"
  done
}

# Why this test is important:
#   - `rm -rf *` or `rm -rf .` typed from the home directory wipes it just as
#     surely as `rm -rf ~`.
# What it tests:
#   - Relative recursive removals are resolved against the hook's cwd, also
#     behind an unknown wrapper: blocked from $HOME, allowed from a project
#     directory, and blocked after a `cd -P ~` earlier in the same command;
#     `git rm -r --cached .` from $HOME is git's rm and allowed.
test_relative_rm_resolved_against_cwd() {
  local c rc
  mkdir -p "$T/project"
  for c in 'rm -rf *' 'rm -rf .' 'rm -rf ./*' '2>/dev/null rm -rf *' 'mise exec -- rm -rf *'; do
    jq -cn --arg c "$c" --arg d "$T" '{cwd: $d, tool_input: {command: $c}}' |
      HOME="$T" bash "$GUARD" >/dev/null 2>&1
    rc=$?
    assert_eq 2 "$rc" "[$c] from \$HOME"
    jq -cn --arg c "$c" --arg d "$T/project" '{cwd: $d, tool_input: {command: $c}}' |
      HOME="$T" bash "$GUARD" >/dev/null 2>&1
    rc=$?
    assert_eq 0 "$rc" "[$c] from a project directory"
  done
  jq -cn --arg d "$T/project" '{cwd: $d, tool_input: {command: "cd -P ~ && rm -rf *"}}' |
    HOME="$T" bash "$GUARD" >/dev/null 2>&1
  rc=$?
  assert_eq 2 "$rc" "[cd -P ~ && rm -rf *] from a project directory"
  jq -cn --arg d "$T" '{cwd: $d, tool_input: {command: "git rm -r --cached ."}}' |
    HOME="$T" bash "$GUARD" >/dev/null 2>&1
  rc=$?
  assert_eq 0 "$rc" "[git rm -r --cached .] from \$HOME"
  jq -cn --arg d "$T" '{cwd: $d, tool_input: {command: "mise exec -- git rm -r --cached ."}}' |
    HOME="$T" bash "$GUARD" >/dev/null 2>&1
  rc=$?
  assert_eq 0 "$rc" "[mise exec -- git rm -r --cached .] from \$HOME"
  jq -cn --arg d "$T/project" '{cwd: $d, tool_input: {command: "git rm -r --cached ~"}}' |
    HOME="$T" bash "$GUARD" >/dev/null 2>&1
  rc=$?
  assert_eq 0 "$rc" "[git rm -r --cached ~]"
}

# Why this test is important:
#   - `git checkout <path>` throws away uncommitted edits exactly like the
#     blocked `git checkout -- <path>`; only the working tree says it's a path.
# What it tests:
#   - From a repo, checking out an existing file or directory (also with
#     --ours) is blocked; checking out a branch name (not a path) is allowed,
#     also with a redirection to an existing file, wrapped or not.
test_checkout_of_existing_path() {
  local c rc
  git -c init.defaultBranch=main init -q "$T/repo"
  mkdir -p "$T/repo/src"
  : > "$T/repo/README.md"
  : > "$T/repo/src/a.txt"
  for c in 'git checkout README.md' 'git checkout src/' 'git checkout --ours src/a.txt'; do
    jq -cn --arg c "$c" --arg d "$T/repo" '{cwd: $d, tool_input: {command: $c}}' | bash "$GUARD" >/dev/null 2>&1
    rc=$?
    assert_eq 2 "$rc" "[$c]"
  done
  # A redirection target is not a checkout path, wrapped or not.
  for c in 'git checkout main' 'git checkout main > README.md' 'mise exec -- git checkout main > README.md'; do
    jq -cn --arg c "$c" --arg d "$T/repo" '{cwd: $d, tool_input: {command: $c}}' | bash "$GUARD" >/dev/null 2>&1
    rc=$?
    assert_eq 0 "$rc" "[$c]"
  done
}

# Why this test is important:
#   - Claude Code shows the hook's stderr; without a reason the block is opaque.
# What it tests:
#   - A blocked command prints a "BLOCKED:" reason on stderr.
test_block_reports_reason() {
  local err
  err=$(jq -cn '{tool_input: {command: "git reset --hard"}}' | bash "$GUARD" 2>&1 >/dev/null)
  assert_contains "$err" "BLOCKED:" "stderr of a blocked command"
}

# Why this test is important:
#   - A guard that silently allows everything when its runtime is missing or
#     its input is unreadable is worse than none; it must fail closed.
# What it tests:
#   - Without python3 on PATH, with a python3 that fails to run (a broken
#     pyenv shim exits 127), and for a malformed payload, the guard exits 2.
test_fails_closed() {
  local rc
  printf '{"tool_input":{"command":"git status"}}' | env PATH="$T/empty" /bin/bash "$GUARD" >/dev/null 2>&1
  rc=$?
  assert_eq 2 "$rc" "exit status without python3"
  mock_cmd python3 "" 127
  printf '{"tool_input":{"command":"git status"}}' | bash "$GUARD" >/dev/null 2>&1
  rc=$?
  assert_eq 2 "$rc" "exit status when python3 fails"
  command rm -f "$MOCK_BIN/python3"
  printf 'not json' | bash "$GUARD" >/dev/null 2>&1
  rc=$?
  assert_eq 2 "$rc" "exit status for a malformed payload"
}

# Why this test is important:
#   - The hook-bypass bans live in guard_rules.json; a missing or corrupt
#     table must block, not silently drop the bans.
# What it tests:
#   - With the table deleted, not JSON, or a row missing fields, `git status`
#     exits 2 and stderr names the guard table.
test_fails_closed_on_bad_table() {
  local table err rc
  command cp -R "$REPO_ROOT/.claude/scripts" "$T/scripts"
  table="$T/scripts/guard_rules.json"
  for bad in missing 'not json' '{"rows":[{"id":1}]}'; do
    if [[ $bad == missing ]]; then command rm -f "$table"; else printf '%s' "$bad" > "$table"; fi
    err=$(jq -cn '{tool_input: {command: "git status"}}' | bash "$T/scripts/guard-bash.sh" 2>&1 >/dev/null)
    rc=$?
    assert_eq 2 "$rc" "exit with a $bad table"
    assert_contains "$err" "guard table" "stderr with a $bad table"
  done
}

run_test test_blocks_destructive_commands
run_test test_allows_everyday_commands
run_test test_force_push_of_current_branch
run_test test_force_push_of_every_branch
run_test test_push_main_outside_refspec
run_test test_relative_rm_resolved_against_cwd
run_test test_checkout_of_existing_path
run_test test_block_reports_reason
run_test test_fails_closed
run_test test_fails_closed_on_bad_table
finish
