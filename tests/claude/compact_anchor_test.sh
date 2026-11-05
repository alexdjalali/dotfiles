#!/usr/bin/env bash
# shellcheck disable=SC2031  # $T is set per test by run_test (tests/lib/assert.sh)
# Tests for .claude/scripts/compact-anchor.sh, the SessionStart hook that
# re-anchors a /spec chain after compaction or resume.
set -uo pipefail
# shellcheck source=../lib/assert.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/assert.sh"

ANCHOR="$REPO_ROOT/.claude/scripts/compact-anchor.sh"

# Runs the hook with a SessionStart payload whose cwd is a git repo in $T.
anchor() {
  git -c init.defaultBranch=main -C "$T" init -q
  jq -cn --arg d "$T" --arg s "${1:-compact}" '{cwd: $d, source: $s}' | bash "$ANCHOR"
}

# A plan file with the given status (and mtime offset in seconds, default 0).
make_plan() {
  local name=$1 status=$2 age=${3:-0}
  mkdir -p "$T/docs/local/plans"
  cat > "$T/docs/local/plans/$name" <<EOF
# Plan: $name

Type: Feature
Status: $status
Approved: Yes
Iteration: 2
Base: abc1234
Reviewed: -
Full gate: -

## Progress Tracking

- **Story 1** — Login · commit: [x]
  - [x] Task 1: add the handler
  - [ ] Task 2: wire the route

**Total:** 2 | **Done:** 1 | **Left:** 1
EOF
  [[ $age -gt 0 ]] && touch -t "$(date -v-"${age}"S +%Y%m%d%H%M.%S)" "$T/docs/local/plans/$name"
  return 0
}

# Why this test is important:
#   - The hook runs on every compaction and resume; printing an anchor when
#     there is no chain in flight would inject noise into unrelated sessions.
# What it tests:
#   - No plan directory, or only VERIFIED plans, gives empty output and exit 0.
test_silent_without_active_plan() {
  local out rc
  out=$(anchor); rc=$?
  assert_eq 0 "$rc" "exit status with no plans"
  assert_eq "" "$out" "output with no plans"
  make_plan done.md VERIFIED
  out=$(anchor); rc=$?
  assert_eq 0 "$rc" "exit status with only a VERIFIED plan"
  assert_eq "" "$out" "output with only a VERIFIED plan"
}

# Why this test is important:
#   - After compaction the model must know which plan, phase, and task it was
#     on, and the SHAs the chain recorded, without re-reading the transcript.
# What it tests:
#   - An active plan yields its path, header fields, progress totals, the first
#     unchecked task, the git position, and the /spec resume command.
test_anchors_active_plan() {
  local out
  make_plan 2026-01-01-login.md PENDING
  out=$(anchor)
  assert_contains "$out" "docs/local/plans/2026-01-01-login.md" "plan path"
  assert_contains "$out" "Status: PENDING" "status"
  assert_contains "$out" "Base: abc1234" "base sha"
  assert_contains "$out" "Total:** 2 | **Done:** 1 | **Left:** 1" "progress"
  assert_contains "$out" "Task 2: wire the route" "next unchecked task"
  assert_contains "$out" "main" "git branch"
  assert_contains "$out" "/spec docs/local/plans/2026-01-01-login.md" "resume command"
}

# Why this test is important:
#   - A finished plan is often the newest file; anchoring to it would resume
#     the wrong work.
# What it tests:
#   - With a newer VERIFIED plan and an older PENDING one, the PENDING plan is
#     the anchor.
test_skips_verified_plan_for_older_active_one() {
  local out
  make_plan 2026-01-01-old.md COMPLETE 120
  make_plan 2026-02-01-new.md VERIFIED
  out=$(anchor)
  assert_contains "$out" "2026-01-01-old.md" "active plan"
  assert_not_contains "$out" "2026-02-01-new.md" "verified plan"
}

# Why this test is important:
#   - A hook that exits non-zero or hangs on a machine without jq would delay
#     every session start.
# What it tests:
#   - With no jq on PATH and an empty payload it falls back to $PWD, still
#     anchors the plan, and exits 0.
test_degrades_without_jq() {
  local bin="$T/nojq" out rc
  make_plan 2026-01-01-login.md PENDING
  mkdir -p "$bin"
  for c in git basename cat grep head ls sed sort tr wc; do
    ln -s "$(command -v "$c")" "$bin/$c"
  done
  git -c init.defaultBranch=main -C "$T" init -q
  out=$(cd "$T" && printf '{}' | PATH="$bin" /bin/bash "$ANCHOR"); rc=$?
  assert_eq 0 "$rc" "exit status without jq"
  assert_contains "$out" "2026-01-01-login.md" "anchor without jq"
}

run_test test_silent_without_active_plan
run_test test_anchors_active_plan
run_test test_skips_verified_plan_for_older_active_one
run_test test_degrades_without_jq
finish
