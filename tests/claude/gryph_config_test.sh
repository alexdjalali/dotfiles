#!/usr/bin/env bash
# Tests for gryph/config.yaml, the tracked config install.sh links to the path
# Gryph reads (ADR-0003: Gryph is a log-only observer).
set -uo pipefail
# shellcheck source=../lib/assert.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/assert.sh"

CONFIG="$REPO_ROOT/gryph/config.yaml"

# Why this test is important:
#   - ADR-0003 adopts Gryph as an observer only. With its policy engine on, a
#     Gryph hook could deny a tool call, and at the default "standard" level it
#     keeps file and command output previews the ADR keeps out of the database.
# What it tests:
#   - The tracked config disables policy, logs at "minimal" with no per-agent
#     override raising it, and states the 90-day retention the ADR relies on
#     instead of inheriting a default.
test_config_is_log_only() {
  assert_eq "false" "$(yq '.policy.enabled' "$CONFIG")" "policy.enabled"
  assert_eq "minimal" "$(yq '.logging.level' "$CONFIG")" "logging.level"
  assert_eq "90" "$(yq '.storage.retention_days' "$CONFIG")" "storage.retention_days"
  assert_eq "0" "$(yq '[.agents // {} | .[] | select(has("logging_level"))] | length' "$CONFIG")" \
    "agents with a logging_level override"
}

run_test test_config_is_log_only
finish
