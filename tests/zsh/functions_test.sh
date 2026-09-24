#!/usr/bin/env bash
# shellcheck disable=SC2031  # $T is set per test by run_test (tests/lib/assert.sh)
# shellcheck disable=SC2016  # zsh code is passed to zsh_with unexpanded on purpose
# Tests for the zsh helper functions in zsh/conf.d/*.zsh.
set -uo pipefail
# shellcheck source=../lib/assert.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/assert.sh"
# shellcheck source=../lib/zsh.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/zsh.sh"

# Why this test is important:
#   - `gca` crashed on the first repo it inspected (zsh's $status is read-only),
#     so the uncommitted-work check silently never worked.
# What it tests:
#   - git-check-all lists every dirty repo under all PROJECT_ROOTS, skips clean
#     ones and missing roots, and writes nothing to stderr.
test_git_check_all_reports_dirty_repos() {
  local out err
  make_repo "$T/r1/alpha" dirty
  make_repo "$T/r1/clean"
  make_repo "$T/r2/beta" dirty
  out=$(PROJECT_ROOTS="$T/r1:$T/missing:$T/r2" zsh_with 'git-check-all' 01-env.zsh 05-functions.zsh 2>"$T/err")
  err=$(cat "$T/err")
  assert_contains "$out" "alpha (main) - 1 uncommitted changes" "git-check-all output"
  assert_contains "$out" "beta (main) - 1 uncommitted changes" "git-check-all output"
  assert_not_contains "$out" "clean" "git-check-all output"
  assert_eq "" "$err" "git-check-all stderr"
}

# Why this test is important:
#   - The project switcher must search the same roots as everything else.
# What it tests:
#   - proj passes every existing PROJECT_ROOTS directory (and no missing one) to fd.
test_proj_searches_project_roots() {
  mkdir -p "$T/r1" "$T/r2"
  mock_cmd fd
  mock_cmd fzf
  PROJECT_ROOTS="$T/r1:$T/missing:$T/r2" zsh_with 'proj' 01-env.zsh 05-functions.zsh >/dev/null 2>&1
  local calls
  calls=$(mock_calls fd)
  assert_contains "$calls" "$T/r1" "fd search paths"
  assert_contains "$calls" "$T/r2" "fd search paths"
  assert_not_contains "$calls" "$T/missing" "fd search paths"
}

# Why this test is important:
#   - With no root present, fd searched the current directory and proj offered
#     unrelated folders instead of saying what was wrong.
# What it tests:
#   - proj reports the missing roots, returns 1, and never calls fd.
test_proj_reports_missing_roots() {
  mock_cmd fd
  mock_cmd fzf
  local out rc
  out=$(PROJECT_ROOTS="$T/missing" zsh_with 'proj' 01-env.zsh 05-functions.zsh 2>&1)
  rc=$?
  assert_eq 1 "$rc" "proj exit status"
  assert_contains "$out" "no PROJECT_ROOTS directory exists" "proj message"
  assert_eq "" "$(mock_calls fd)" "fd calls"
}

# Why this test is important:
#   - nvim-restore ran `rm -rf` over the git-tracked nvim config; vs/vl/vw saved
#     empty sessions; _make_targets replaced zsh's better built-in completion.
# What it tests:
#   - None of these helpers is defined after loading the completion and
#     function modules.
test_removed_helpers_absent() {
  local out
  out=$(zsh_with 'for f in nvim-backup nvim-restore vs vl vw _make_targets; do whence -w $f; done' \
    compinit 02-completions.zsh 05-functions.zsh 2>/dev/null)
  local f
  for f in nvim-backup nvim-restore vs vl vw _make_targets; do
    assert_contains "$out" "$f: none" "whence -w output"
  done
}

# Why this test is important:
#   - With `exec bash || exec sh` as two commands, leaving a bash session with a
#     non-zero status silently opened a second shell.
# What it tests:
#   - dexec runs exactly one `docker exec`, which picks bash or sh inside the
#     container, even when the session exits non-zero.
test_dexec_runs_one_exec() {
  mock_cmd docker "" 1
  zsh_with 'dexec web' 05-functions.zsh >/dev/null 2>&1
  local calls
  calls=$(mock_calls docker)
  assert_eq 1 "$(grep -c . <<<"$calls")" "number of docker calls"
  assert_contains "$calls" "exec -it web sh -c" "docker call"
}

# Why this test is important:
#   - Same double-shell bug as dexec, for pods.
# What it tests:
#   - kexec runs exactly one `kubectl exec`, which picks bash or sh in the pod.
test_kexec_runs_one_exec() {
  mock_cmd kubectl "" 1
  zsh_with 'kexec api-0' 05-functions.zsh >/dev/null 2>&1
  local calls
  calls=$(mock_calls kubectl)
  assert_eq 1 "$(grep -c . <<<"$calls")" "number of kubectl calls"
  assert_contains "$calls" "exec -it api-0 -- sh -c" "kubectl call"
}

# Why this test is important:
#   - helpme is the searchable index of every alias and function; entries it
#     misses are effectively undiscoverable.
# What it tests:
#   - The list handed to fzf includes functions declared with the `function`
#     keyword (rainbow_sep in 07-visual.zsh), aliases defined inside an
#     if-block (the eza `ls` alias in 04-aliases.zsh), and the machine-only
#     aliases in ~/.zshrc.local.
test_helpme_lists_function_keyword_and_indented_aliases() {
  mock_cmd fzf
  printf "alias localonly='echo hi'\n" > "$T/.zshrc.local"
  zsh_with 'helpme' 06-fzf.zsh >/dev/null 2>&1
  local listed
  listed=$(cat "$MOCK_DIR/fzf.stdin")
  grep -qE '^rainbow_sep +\(function\)' <<<"$listed" || _fail "helpme entries: no rainbow_sep function in [$listed]"
  grep -qE '^ls +.*eza --icons' <<<"$listed" || _fail "helpme entries: no eza-backed 'ls' alias in [$listed]"
  grep -qE '^localonly +.*echo hi' <<<"$listed" || _fail "helpme entries: no ~/.zshrc.local alias in [$listed]"
}

# Why this test is important:
#   - The search helpers only turned spaces into +, so an apostrophe, & or #
#     produced a broken or truncated search (same bug as the Raycast scripts).
# What it tests:
#   - search-github, search-so, search-go and search-pypi open URLs with the
#     query form-encoded.
test_search_functions_encode_query() {
  mock_cmd open
  zsh_with 'search-github "don'"'"'t panic"; search-so "a&b"; search-go "x#y"; search-pypi "c++"' 05-functions.zsh
  assert_eq "https://github.com/search?q=don%27t+panic&type=repositories
https://stackoverflow.com/search?q=a%26b
https://pkg.go.dev/search?q=x%23y
https://pypi.org/search/?q=c%2B%2B" "$(mock_calls open)" "URLs opened"
}

run_test test_git_check_all_reports_dirty_repos
run_test test_proj_searches_project_roots
run_test test_proj_reports_missing_roots
run_test test_removed_helpers_absent
run_test test_dexec_runs_one_exec
run_test test_kexec_runs_one_exec
run_test test_helpme_lists_function_keyword_and_indented_aliases
run_test test_search_functions_encode_query
finish
