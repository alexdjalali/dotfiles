#!/usr/bin/env bash
# Tests for .claude/scripts/guard-sensitive.sh, the Read/Edit/Write PreToolUse
# hook that asks the user before a call touches a secrets file, edits the
# guards or settings that police the agent, or writes text gitleaks flags as
# a secret.
set -uo pipefail
# shellcheck source=../lib/assert.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/assert.sh"

GUARD="$REPO_ROOT/.claude/scripts/guard-sensitive.sh"

# The guard's verdict (ask / pass) for tool $1 on path $2, with Edit's
# new_string / Write's content set to $3.
guard_status() {
  jq -cn --arg t "$1" --arg p "$2" --arg n "${3-}" \
    '{tool_name: $t, tool_input: ({file_path: $p} + (if $t == "Write" then {content: $n} else {old_string: "x", new_string: $n} end))}' |
    verdict bash "$GUARD"
}

# Why this test is important:
#   - A secret read into the conversation is sent to the model provider and
#     kept in the transcript; the user must see that before it happens.
# What it tests:
#   - Read of .env, .env.production, a .pem, an SSH private key, a tfstate,
#     ~/.aws/credentials and a kube config asks; an Edit of .env asks too.
test_asks_for_secret_files() {
  local p
  for p in "$T/.env" "$T/.env.production" "$T/tls.pem" "$T/.ssh/id_ed25519" \
    "$T/terraform.tfstate" "$T/.aws/credentials" "$T/.kube/config" "$T/secrets.yaml"; do
    assert_eq ask "$(guard_status Read "$p")" "Read $p"
  done
  assert_eq ask "$(guard_status Edit "$T/.env" 'A=1')" "Edit .env"
}

# Why this test is important:
#   - Templates and public keys are meant to be read; asking about them would
#     train the user to approve every prompt.
# What it tests:
#   - .env.example, .env.sample, id_ed25519.pub, and ordinary source and
#     config files pass.
test_allows_templates_and_public_keys() {
  local p
  for p in "$T/.env.example" "$T/.env.sample" "$T/.ssh/id_ed25519.pub" "$T/main.go" "$T/config.yaml"; do
    assert_eq pass "$(guard_status Read "$p")" "Read $p"
  done
}

# Why this test is important:
#   - The guards only hold if the agent cannot quietly edit them, or the
#     settings that wire them, out of the way.
# What it tests:
#   - Edit/Write of .claude/settings.json, settings.local.json, a guard
#     script, guard_rules.json and hook_lib.sh asks; Read of them passes.
test_asks_before_editing_guards_and_settings() {
  local p
  for p in "$T/.claude/settings.json" "$T/.claude/settings.local.json" \
    "$T/.claude/scripts/guard-bash.sh" "$T/.claude/scripts/guard_rules.json" "$T/.claude/scripts/hook_lib.sh"; do
    assert_eq ask "$(guard_status Edit "$p" 'x')" "Edit $p"
    assert_eq ask "$(guard_status Write "$p" 'x')" "Write $p"
    assert_eq pass "$(guard_status Read "$p")" "Read $p"
  done
  assert_eq pass "$(guard_status Edit "$T/.claude/scripts/statusline.sh" 'x')" "an unguarded script"
}

# Why this test is important:
#   - A hard-coded credential written into a source file ends up committed
#     and pushed; gitleaks catches the common shapes before the write.
# What it tests:
#   - When gitleaks reports a leak (exit 9) the Edit asks and the reason
#     names the rule, not the secret; when it reports none the Edit passes;
#     the text reaches gitleaks on stdin.
test_scans_written_text_with_gitleaks() {
  mock_cmd gitleaks '[{"RuleID":"aws-access-token","Secret":"REDACTED"}]' 9
  local out
  out=$(jq -cn --arg p "$T/a.go" '{tool_name: "Edit", tool_input: {file_path: $p, old_string: "x", new_string: "key := k"}}' |
    bash "$GUARD" 2>/dev/null)
  assert_eq ask "$(jq -r '.hookSpecificOutput.permissionDecision' <<<"$out")" "decision on a leak"
  assert_contains "$out" "aws-access-token" "reason names the rule"
  assert_contains "$(cat "$MOCK_DIR/gitleaks.stdin")" "key := k" "text sent to gitleaks"
  mock_cmd gitleaks '[]' 0
  assert_eq pass "$(guard_status Write "$T/a.go" 'x := 1')" "clean text"
}

# Why this test is important:
#   - A scanner that errors has checked nothing; staying silent would let a
#     secret through, while a missing scanner is an install choice.
# What it tests:
#   - A gitleaks that fails (exit 1) asks; with no gitleaks on PATH the Edit
#     passes unscanned.
test_gitleaks_failure_asks_absence_passes() {
  mock_cmd gitleaks '' 1
  assert_eq ask "$(guard_status Edit "$T/a.go" 'x := 1')" "gitleaks fails"
  mkdir -p "$T/bin"
  ln -s "$(command -v jq)" "$T/bin/jq"
  assert_eq pass "$(jq -cn --arg p "$T/a.go" '{tool_name: "Edit", tool_input: {file_path: $p, new_string: "x"}}' |
    verdict env PATH="$T/bin:/usr/bin:/bin" bash "$GUARD")" "no gitleaks"
}

# Why this test is important:
#   - A guard that allows what it cannot read fails open.
# What it tests:
#   - Malformed JSON gets an "ask" decision.
test_asks_on_bad_json() {
  assert_eq ask "$(printf 'not json' | verdict bash "$GUARD")" "malformed payload"
}

run_test test_asks_for_secret_files
run_test test_allows_templates_and_public_keys
run_test test_asks_before_editing_guards_and_settings
run_test test_scans_written_text_with_gitleaks
run_test test_gitleaks_failure_asks_absence_passes
run_test test_asks_on_bad_json
finish
