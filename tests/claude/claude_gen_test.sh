#!/usr/bin/env bash
# shellcheck disable=SC2031  # $T is set per test by run_test (tests/lib/assert.sh)
# Tests for claude-gen (.claude/gen), the generator that renders the agent
# config from .claude/src: its Go suite, and that the committed outputs match
# a fresh render.
set -uo pipefail
# shellcheck source=../lib/assert.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/assert.sh"

GEN="$REPO_ROOT/.claude/gen"

# Why this test is important:
#   - The generator's unit and golden tests are Go; `just test` runs shell
#     tests, so this is how they join the gate.
# What it tests:
#   - `go test ./...` in .claude/gen exits 0.
test_go_suite_passes() {
  local out
  out=$(go -C "$GEN" test ./... 2>&1) || _fail "go test failed: $out"
}

# Why this test is important:
#   - A hand-edited or stale generated file is invisible until the next
#     regenerate silently reverts it; the check makes it fail now.
# What it tests:
#   - `claude-gen --check` against this checkout reports no drift.
test_committed_outputs_match_render() {
  local out
  out=$(go -C "$GEN" run . --root "$REPO_ROOT" --check 2>&1) || _fail "drift: $out"
}

# Why this test is important:
#   - The catalog exists so each rule is written once; a statement pasted into
#     a template drifts from the catalog on the next edit.
# What it tests:
#   - No rule statement from .claude/src/rules.yaml appears verbatim in any
#     .claude/src template (they use {{rule "id"}} instead).
test_templates_reference_catalog() {
  local statement hits
  while IFS= read -r statement; do
    [[ -n $statement ]] || continue
    hits=$(grep -rlF --include='*.tmpl' -- "$statement" "$REPO_ROOT/.claude/src")
    assert_eq "" "$hits" "templates repeating: $statement"
  done < <(yq -r '.[].statement' "$REPO_ROOT/.claude/src/rules.yaml")
}

# Why this test is important:
#   - Claude Code silently skips a skill whose frontmatter it cannot load, so a
#     generator slip would drop a command without any error.
# What it tests:
#   - `claude plugin validate` accepts every generated skill with no warning
#     (it exits 0 on warnings such as a missing description, so those fail
#     here too); without the claude CLI the test fails rather than skipping.
test_generated_skills_validate() {
  command -v claude >/dev/null || _fail "claude CLI required"
  local out
  out=$(claude plugin validate "$REPO_ROOT/.claude/skills" 2>&1) || _fail "validate failed: $out"
  assert_not_contains "$out" "warning" "validate warned"
}

run_test test_go_suite_passes
run_test test_committed_outputs_match_render
run_test test_templates_reference_catalog
run_test test_generated_skills_validate
finish
