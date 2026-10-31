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

run_test test_go_suite_passes
run_test test_committed_outputs_match_render
finish
