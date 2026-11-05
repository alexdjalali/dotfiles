#!/usr/bin/env bash
# shellcheck disable=SC2031  # $T is set per test by run_test (tests/lib/assert.sh)
# Tests for claude-gen (.claude/gen), the generator that renders the agent
# config from .claude/src: its Go suite, that templates reference the rule
# catalog instead of repeating it, and that the generated skills validate.
# Drift between the committed outputs and a fresh render is `just lint`'s
# `claude-gen --check`.
set -uo pipefail
# shellcheck source=../lib/assert.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/assert.sh"

GEN="$REPO_ROOT/.claude/gen"

# The generator's unit and golden tests are Go; `just test` runs shell tests, so this is how they join the gate.
test_go_suite_passes() {
  local out
  out=$(go -C "$GEN" test ./... 2>&1) || _fail "go test failed: $out"
}

# The catalog exists so each rule is written once; a statement pasted into a template drifts from the catalog on the next edit.
test_templates_reference_catalog() {
  local text hits
  while IFS= read -r text; do
    [[ -n $text ]] || continue
    hits=$(grep -rlF --include='*.tmpl' -- "$text" "$REPO_ROOT/.claude/src")
    assert_eq "" "$hits" "templates repeating: $text"
  done < <(yq -r '.[] | (.statement, .summary) | select(. != null)' "$REPO_ROOT/.claude/src/rules.yaml")
}

# Claude Code silently skips a skill whose frontmatter it cannot load, so a generator slip would drop a command without any error.
test_generated_skills_validate() {
  command -v claude >/dev/null || _fail "claude CLI required"
  local out
  out=$(claude plugin validate "$REPO_ROOT/.claude/skills" 2>&1) || _fail "validate failed: $out"
  assert_not_contains "$out" "warning" "validate warned"
}

run_test test_go_suite_passes
run_test test_templates_reference_catalog
run_test test_generated_skills_validate
finish
