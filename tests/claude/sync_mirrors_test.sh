#!/usr/bin/env bash
# shellcheck disable=SC2031  # $T is set per test by run_test (tests/lib/assert.sh)
# Tests for .claude/scripts/sync-mirrors.sh, which generates kilocode/rules/
# from cursor/rules/. Every run works on a temp copy of both directories.
set -uo pipefail
# shellcheck source=../lib/assert.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/assert.sh"

SYNC="$REPO_ROOT/.claude/scripts/sync-mirrors.sh"

# A copy of this checkout's cursor/ and kilocode/ rules under $T/repo.
copy_rules() {
  mkdir -p "$T/repo/cursor" "$T/repo/kilocode"
  cp -R "$REPO_ROOT/cursor/rules" "$T/repo/cursor/rules"
  cp -R "$REPO_ROOT/kilocode/rules" "$T/repo/kilocode/rules"
}

# Why this test is important:
#   - The Kilocode rules were a hand-kept copy of the Cursor rules; the generator
#     is only safe to adopt if it reproduces them exactly.
# What it tests:
#   - Generating from the Cursor rules into an empty Kilocode dir yields the
#     committed Kilocode rules, byte for byte.
test_generate_matches_committed_kilocode() {
  copy_rules
  command rm -f "$T"/repo/kilocode/rules/*
  bash "$SYNC" "$T/repo" || _fail "sync-mirrors.sh failed"
  local out
  out=$(diff -r "$REPO_ROOT/kilocode/rules" "$T/repo/kilocode/rules")
  assert_eq "" "$out" "generated vs committed kilocode/rules"
}

# Why this test is important:
#   - A drift check that fails on a clean tree would be ignored.
# What it tests:
#   - `--check` exits 0 on an in-sync copy.
test_check_passes_when_in_sync() {
  copy_rules
  bash "$SYNC" --check "$T/repo" || _fail "--check failed on an in-sync tree"
}

# Why this test is important:
#   - Hand edits to kilocode/rules/ (or a Cursor edit without a regenerate) are
#     exactly what the check exists to catch.
# What it tests:
#   - `--check` exits 1 and names the file when a Kilocode rule differs from its
#     Cursor source, and when a Kilocode rule has no Cursor source.
test_check_detects_drift() {
  copy_rules
  echo "hand edit" >> "$T/repo/kilocode/rules/go.md"
  : > "$T/repo/kilocode/rules/orphan.md"
  local err rc
  err=$(bash "$SYNC" --check "$T/repo" 2>&1 >/dev/null)
  rc=$?
  assert_eq 1 "$rc" "--check exit status with drift"
  assert_contains "$err" "kilocode/rules/go.md" "--check report"
  assert_contains "$err" "kilocode/rules/orphan.md" "--check report"
}

# Why this test is important:
#   - kilocode/rules/ is generated; a rule renamed or removed in Cursor must not
#     leave a stale Kilocode copy that --check then flags forever.
# What it tests:
#   - Generating deletes a Kilocode rule that has no Cursor source.
test_generate_removes_orphans() {
  copy_rules
  : > "$T/repo/kilocode/rules/orphan.md"
  bash "$SYNC" "$T/repo" || _fail "sync-mirrors.sh failed"
  [[ -e "$T/repo/kilocode/rules/orphan.md" ]] && _fail "orphan.md survived"
  bash "$SYNC" --check "$T/repo" || _fail "--check failed after generating"
}

run_test test_generate_matches_committed_kilocode
run_test test_check_passes_when_in_sync
run_test test_check_detects_drift
run_test test_generate_removes_orphans
finish
