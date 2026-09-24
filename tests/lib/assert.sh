#!/usr/bin/env bash
# Shared assertions and command mocks for tests/*/*_test.sh.
#
# A test file sources this, defines test functions, calls `run_test <fn>` for
# each, and ends with `finish` (prints a summary; non-zero exit on any failure).
# Each test runs in its own subshell with a throwaway $T (mktemp) that is removed
# afterwards, so tests are independent and never touch the real $HOME.
#
# `mock_cmd NAME [STDOUT] [EXIT]` puts a PATH shim for an external command in
# front of PATH: each call appends its argv (one line) to $MOCK_DIR/NAME.calls
# and its stdin to $MOCK_DIR/NAME.stdin, prints STDOUT, and exits with EXIT.
# The shim always reads stdin, so give the code under test explicit stdin
# (`</dev/null`, a pipe, or a heredoc).

# shellcheck disable=SC2034  # read by the test files that source this library
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
_PASSED=0
_FAILED=0

_fail() {
  printf '      %s\n' "$*"
  exit 1
}

assert_eq() {
  [[ "$1" == "$2" ]] || _fail "$3: expected [$1], got [$2]"
}

assert_contains() {
  [[ "$1" == *"$2"* ]] || _fail "$3: [$2] not found in [$1]"
}

assert_not_contains() {
  [[ "$1" != *"$2"* ]] || _fail "$3: unexpected [$2] in [$1]"
}

mock_cmd() {
  local name=$1 out=${2-} code=${3-0}
  {
    printf '#!/usr/bin/env bash\n'
    printf 'printf "%%s\\n" "$*" >> %q\n' "$MOCK_DIR/$name.calls"
    printf 'cat >> %q\n' "$MOCK_DIR/$name.stdin"
    printf 'printf "%%s" %q\n' "$out"
    printf 'exit %d\n' "$code"
  } > "$MOCK_BIN/$name"
  chmod +x "$MOCK_BIN/$name"
}

# The calls recorded for a mocked command, one argv per line (empty if none).
mock_calls() {
  cat "$MOCK_DIR/$1.calls" 2>/dev/null
}

# A git repo at $1 on branch main; "dirty" adds an untracked file.
make_repo() {
  git -c init.defaultBranch=main init -q "$1"
  [[ ${2-} == dirty ]] && : > "$1/untracked.txt"
  return 0
}

run_test() {
  local fn=$1 out rc
  out=$(
    T=$(mktemp -d)
    trap 'rm -rf "$T"' EXIT
    MOCK_DIR="$T/.mocks"
    MOCK_BIN="$T/.mocks/bin"
    mkdir -p "$MOCK_BIN"
    PATH="$MOCK_BIN:$PATH"
    "$fn" 2>&1
  )
  rc=$?
  if [[ $rc -eq 0 ]]; then
    _PASSED=$((_PASSED + 1))
    printf '  ok    %s\n' "$fn"
  else
    _FAILED=$((_FAILED + 1))
    printf '  FAIL  %s\n%s\n' "$fn" "$out"
  fi
}

finish() {
  printf '%d passed, %d failed\n' "$_PASSED" "$_FAILED"
  [[ $_FAILED -eq 0 ]]
}
