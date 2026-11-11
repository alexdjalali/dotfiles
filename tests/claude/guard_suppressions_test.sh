#!/usr/bin/env bash
# Tests for .claude/scripts/guard-suppressions.sh, the PreToolUse hook that
# asks the user before an Edit/Write adds a lint/type/security suppression or growing
# an exemption list.
set -uo pipefail
# shellcheck source=../lib/assert.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/assert.sh"

GUARD="$REPO_ROOT/.claude/scripts/guard-suppressions.sh"

# The guard's verdict (ask / pass) for an Edit of $1 replacing $2 with $3.
edit_status() {
  jq -cn --arg p "$1" --arg o "$2" --arg n "$3" \
    '{tool_name: "Edit", tool_input: {file_path: $p, old_string: $o, new_string: $n}}' |
    verdict bash "$GUARD"
}

# The guard's verdict (ask / pass) for a Write of $2 to $1.
write_status() {
  jq -cn --arg p "$1" --arg c "$2" '{tool_name: "Write", tool_input: {file_path: $p, content: $c}}' |
    verdict bash "$GUARD"
}

# Why this test is important:
#   - An agent asked to get a check green takes the cheapest path, and an
#     inline suppression is the cheapest path there is.
# What it tests:
#   - An Edit that adds //nolint, #nosec, # noqa, type: ignore, pyright:
#     ignore, eslint-disable, @ts-expect-error or nosemgrep asks.
test_asks_added_markers() {
  assert_eq ask "$(edit_status "$T/a.go" 'x := f()' 'x := f() //nolint:errcheck')" "nolint"
  assert_eq ask "$(edit_status "$T/a.go" 'f()' 'f() // #nosec G204')" "nosec"
  assert_eq ask "$(edit_status "$T/a.py" 'x = f()' 'x = f()  # noqa: E501')" "noqa"
  assert_eq ask "$(edit_status "$T/a.py" 'x = f()' 'x = f()  # type: ignore[arg-type]')" "type: ignore"
  assert_eq ask "$(edit_status "$T/a.py" 'x = f()' 'x = f()  # pyright: ignore')" "pyright: ignore"
  assert_eq ask "$(edit_status "$T/a.ts" 'f()' '// eslint-disable-next-line\nf()')" "eslint-disable"
  assert_eq ask "$(edit_status "$T/a.ts" 'f()' '// @ts-expect-error\nf()')" "ts-expect-error"
  assert_eq ask "$(edit_status "$T/a.go" 'f()' 'f() // nosemgrep')" "nosemgrep"
}

# Why this test is important:
#   - A bare prompt leaves the user and the agent guessing; the reason must
#     point at the fix and at the human-owned path for changing the rule.
# What it tests:
#   - The decision's reason says "fix the code" and names the edited file.
test_reason_names_the_alternative() {
  local reason
  reason=$(jq -cn --arg p "$T/a.go" '{tool_input: {file_path: $p, old_string: "f()", new_string: "f() //nolint"}}' |
    bash "$GUARD" 2>/dev/null | jq -r '.hookSpecificOutput.permissionDecisionReason')
  assert_contains "$reason" "fix the code" "reason"
  assert_contains "$reason" "$T/a.go" "reason names the file"
}

# Why this test is important:
#   - Refactors move and delete existing suppressions; blocking those would
#     make the guard punish cleanup.
# What it tests:
#   - An Edit with the same marker count, or fewer, passes.
test_allows_unchanged_marker_count() {
  assert_eq pass "$(edit_status "$T/a.go" 'f() //nolint:errcheck' 'g() //nolint:errcheck')" "same count"
  assert_eq pass "$(edit_status "$T/a.go" 'f() //nolint:errcheck' 'f()')" "removal"
}

# Why this test is important:
#   - Write replaces a whole file and has no old_string, so the guard must
#     compare against what is on disk or it would miss (or invent) additions.
# What it tests:
#   - Rewriting a file with the same markers passes; adding one, or creating
#     a new file that carries one, asks.
test_write_compares_with_existing_file() {
  printf 'x = 1  # noqa\n' > "$T/old.py"
  assert_eq pass "$(write_status "$T/old.py" $'x = 2  # noqa\n')" "rewrite keeping one"
  assert_eq ask "$(write_status "$T/old.py" $'x = 2  # noqa\ny = 3  # noqa\n')" "rewrite adding one"
  assert_eq ask "$(write_status "$T/new.py" $'y = 3  # type: ignore\n')" "new file with one"
}

# Why this test is important:
#   - Exemption lists are the other way agents silence checks: one more line
#     in a baseline file and the gate goes green.
# What it tests:
#   - A baseline, .trivyignore or allowlist that gains lines asks; one
#     that shrinks passes.
test_asks_growing_exemption_files() {
  printf '{"a": 1}\n' > "$T/conformance_exemptions_baseline.json"
  assert_eq ask "$(write_status "$T/conformance_exemptions_baseline.json" $'{"a": 1,\n "b": 2}\n')" "baseline grows"
  assert_eq pass "$(write_status "$T/conformance_exemptions_baseline.json" $'{}\n')" "baseline shrinks"
  assert_eq ask "$(edit_status "$T/.trivyignore" 'CVE-1' $'CVE-1\nCVE-2')" "trivyignore grows"
  assert_eq ask "$(edit_status "$T/lint-allowlist.yaml" 'a' $'a\nb')" "allowlist grows"
}

# Why this test is important:
#   - Rules and docs talk about //nolint; a guard that blocked them would stop
#     the very docs that explain the policy.
# What it tests:
#   - A Markdown edit mentioning a marker, a plain code edit, and a payload
#     with no path all pass.
test_allows_markdown_and_plain_code() {
  assert_eq pass "$(edit_status "$T/README.md" 'x' 'never add //nolint')" "markdown"
  assert_eq pass "$(edit_status "$T/a.go" 'x := 1' 'x := 2')" "plain code"
  assert_eq pass "$(edit_status "" 'x' 'y')" "no path"
}

# Why this test is important:
#   - A guard that allows what it cannot read fails open.
# What it tests:
#   - Malformed JSON asks.
test_asks_bad_json() {
  assert_eq ask "$(printf 'not json' | verdict bash "$GUARD")" "malformed payload"
}

run_test test_asks_added_markers
run_test test_reason_names_the_alternative
run_test test_allows_unchanged_marker_count
run_test test_write_compares_with_existing_file
run_test test_asks_growing_exemption_files
run_test test_allows_markdown_and_plain_code
run_test test_asks_bad_json
finish
