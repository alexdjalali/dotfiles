#!/usr/bin/env bash
# hook_lib.sh — shared by the PreToolUse guard scripts; source it, don't run it.
#
# Guards never refuse outright: a call one catches goes to the user's
# permission prompt through a `permissionDecision: "ask"` decision (exit 0,
# JSON on stdout), labelled [settings] with the reason, even in auto mode.
# The user's approval is the override. A guard that cannot do its check
# (no jq, an unreadable payload) asks too, so a broken guard never lets a
# call through unseen. Headless runs (`claude -p`) have no prompt and treat
# "ask" as a refusal.

# hook_ask <guard> <reason>: print the "ask" decision for reason and exit 0.
# The JSON is built in bash so asking works even without jq.
hook_ask() {
  local reason="$1: $2"
  reason=${reason//\\/\\\\}
  reason=${reason//\"/\\\"}
  reason=${reason//$'\n'/ }
  reason=${reason//$'\t'/ }
  reason=${reason//$'\r'/ }
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"%s"}}\n' "$reason"
  exit 0
}

# hook_payload <guard> <var>: read the hook payload on stdin (compact JSON)
# into the variable named var; ask when jq is missing or the payload is not
# JSON. Call it directly, not in $(...): hook_ask must exit the guard itself.
hook_payload() {
  local json
  command -v jq >/dev/null 2>&1 || hook_ask "$1" "needs jq to read the hook payload, so the call was not checked"
  json=$(jq -ec '.' 2>/dev/null) || hook_ask "$1" "could not read the hook payload, so the call was not checked"
  printf -v "$2" '%s' "$json"
}
