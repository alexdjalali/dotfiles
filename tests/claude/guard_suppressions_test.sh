#!/usr/bin/env bash
# shellcheck disable=SC2031  # $T is set per test by run_test (tests/lib/assert.sh)
# Tests for .claude/scripts/guard-suppressions.sh, the PreToolUse hook that
# blocks an Edit/Write from adding a lint/type/security suppression or growing
# an exemption list.
set -uo pipefail
# shellcheck source=../lib/assert.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/assert.sh"

GUARD="$REPO_ROOT/.claude/scripts/guard-suppressions.sh"

# Exit status of the guard for an Edit of $1 replacing $2 with $3.
edit_status() {
  jq -cn --arg p "$1" --arg o "$2" --arg n "$3" \
    '{tool_name: "Edit", tool_input: {file_path: $p, old_string: $o, new_string: $n}}' |
    bash "$GUARD" >/dev/null 2>&1
  echo $?
}

# Exit status of the guard for a Write of $2 to $1.
write_status() {
  jq -cn --arg p "$1" --arg c "$2" '{tool_name: "Write", tool_input: {file_path: $p, content: $c}}' |
    bash "$GUARD" >/dev/null 2>&1
  echo $?
}

# Each suppression marker an agent reaches for is blocked when an edit adds it.
test_blocks_added_markers() {
  assert_eq 2 "$(edit_status "$T/a.go" 'x := f()' 'x := f() //nolint:errcheck')" "nolint"
  assert_eq 2 "$(edit_status "$T/a.go" 'f()' 'f() // #nosec G204')" "nosec"
  assert_eq 2 "$(edit_status "$T/a.py" 'x = f()' 'x = f()  # noqa: E501')" "noqa"
  assert_eq 2 "$(edit_status "$T/a.py" 'x = f()' 'x = f()  # type: ignore[arg-type]')" "type: ignore"
  assert_eq 2 "$(edit_status "$T/a.py" 'x = f()' 'x = f()  # pyright: ignore')" "pyright: ignore"
  assert_eq 2 "$(edit_status "$T/a.ts" 'f()' '// eslint-disable-next-line\nf()')" "eslint-disable"
  assert_eq 2 "$(edit_status "$T/a.ts" 'f()' '// @ts-expect-error\nf()')" "ts-expect-error"
  assert_eq 2 "$(edit_status "$T/a.go" 'f()' 'f() // nosemgrep')" "nosemgrep"
}

# The block message tells the agent what to do instead.
test_reason_names_the_alternative() {
  local err
  err=$(jq -cn --arg p "$T/a.go" '{tool_input: {file_path: $p, old_string: "f()", new_string: "f() //nolint"}}' |
    bash "$GUARD" 2>&1 >/dev/null)
  assert_contains "$err" "fix the code" "reason"
  assert_contains "$err" "$T/a.go" "reason names the file"
}

# Moving or keeping an existing suppression is not adding one.
test_allows_unchanged_marker_count() {
  assert_eq 0 "$(edit_status "$T/a.go" 'f() //nolint:errcheck' 'g() //nolint:errcheck')" "same count"
  assert_eq 0 "$(edit_status "$T/a.go" 'f() //nolint:errcheck' 'f()')" "removal"
}

# A Write counts against the file's current contents.
test_write_compares_with_existing_file() {
  printf 'x = 1  # noqa\n' > "$T/old.py"
  assert_eq 0 "$(write_status "$T/old.py" $'x = 2  # noqa\n')" "rewrite keeping one"
  assert_eq 2 "$(write_status "$T/old.py" $'x = 2  # noqa\ny = 3  # noqa\n')" "rewrite adding one"
  assert_eq 2 "$(write_status "$T/new.py" $'y = 3  # type: ignore\n')" "new file with one"
}

# Exemption, baseline and allowlist files may shrink but not grow.
test_blocks_growing_exemption_files() {
  printf '{"a": 1}\n' > "$T/conformance_exemptions_baseline.json"
  assert_eq 2 "$(write_status "$T/conformance_exemptions_baseline.json" $'{"a": 1,\n "b": 2}\n')" "baseline grows"
  assert_eq 0 "$(write_status "$T/conformance_exemptions_baseline.json" $'{}\n')" "baseline shrinks"
  assert_eq 2 "$(edit_status "$T/.trivyignore" 'CVE-1' $'CVE-1\nCVE-2')" "trivyignore grows"
  assert_eq 2 "$(edit_status "$T/lint-allowlist.yaml" 'a' $'a\nb')" "allowlist grows"
}

# Docs and ordinary code that mention a marker in prose are not suppressions.
test_allows_markdown_and_plain_code() {
  assert_eq 0 "$(edit_status "$T/README.md" 'x' 'never add //nolint')" "markdown"
  assert_eq 0 "$(edit_status "$T/a.go" 'x := 1' 'x := 2')" "plain code"
  assert_eq 0 "$(edit_status "" 'x' 'y')" "no path"
}

# A guard that cannot read its payload fails closed.
test_blocks_bad_json() {
  printf 'not json' | bash "$GUARD" >/dev/null 2>&1
  assert_eq 2 "$?" "exit for malformed payload"
}

run_test test_blocks_added_markers
run_test test_reason_names_the_alternative
run_test test_allows_unchanged_marker_count
run_test test_write_compares_with_existing_file
run_test test_blocks_growing_exemption_files
run_test test_allows_markdown_and_plain_code
run_test test_blocks_bad_json
finish
