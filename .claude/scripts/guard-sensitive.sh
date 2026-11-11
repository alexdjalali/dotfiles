#!/usr/bin/env bash
# guard-sensitive.sh
#
# Claude Code PreToolUse hook for Read, Edit and Write. The calls below go to
# the user's permission prompt (an "ask" decision, hook_lib.sh); the user's
# approval is the override:
#   - any call on a secrets file: .env / .env.* (not .example / .sample /
#     .template), *.pem, *.key, *.p12, *.pfx, SSH private keys (id_rsa*,
#     id_ecdsa*, id_ed25519*, not *.pub), *.tfstate, .netrc, .pgpass,
#     secrets.{yaml,yml,json}, ~/.aws/credentials, ~/.kube/config,
#     ~/.docker/config.json. A secret read into context is sent to the model
#     provider and kept in the transcript;
#   - an Edit or Write of what polices the agent: .claude/settings.json,
#     .claude/settings.local.json, and .claude/scripts/guard* / hook_lib.sh;
#   - an Edit or Write whose new text gitleaks (`gitleaks stdin`) flags as a
#     secret. The reason names the gitleaks rule, never the secret. A gitleaks
#     that fails asks; no gitleaks on PATH skips the scan.
#
# Not covered: the same files reached through Bash (`cat .env`), and guard
# rows changed through their source (.claude/src/rules.yaml) and a regenerate.
# The hook fails toward the prompt: a payload it cannot read, or a missing
# jq, asks.
set -uo pipefail

here=${BASH_SOURCE[0]%/*}
[[ $here == "${BASH_SOURCE[0]}" ]] && here=.
# shellcheck source=hook_lib.sh
source "$here/hook_lib.sh" || exit 2

payload=""
hook_payload guard-sensitive payload
tool=$(jq -r '.tool_name // ""' <<<"$payload")
path=$(jq -r '.tool_input.file_path // ""' <<<"$payload")
[[ -n $path ]] || exit 0
base=${path##*/}

case $base in
  .env.example | .env.sample | .env.template | *.pub) ;;
  .env | .env.* | *.pem | *.key | *.p12 | *.pfx | id_rsa* | id_ecdsa* | id_ed25519* | \
    *.tfstate | *.tfstate.backup | .netrc | .pgpass | secrets.yaml | secrets.yml | secrets.json)
    hook_ask guard-sensitive "$tool of a secrets file ($path); its contents would enter the conversation"
    ;;
esac
case $path in
  */.aws/credentials | */.kube/config | */.docker/config.json)
    hook_ask guard-sensitive "$tool of a credentials file ($path); its contents would enter the conversation"
    ;;
esac

[[ $tool == Edit || $tool == Write ]] || exit 0

case $path in
  */.claude/settings.json | */.claude/settings.local.json | */.claude/scripts/guard* | */.claude/scripts/hook_lib.sh)
    hook_ask guard-sensitive "$tool of a guard or the settings that wire the guards ($path)"
    ;;
esac

command -v gitleaks >/dev/null 2>&1 || exit 0
text=$(jq -r '.tool_input | (.new_string // .content // "")' <<<"$payload")
[[ -n $text ]] || exit 0
report=$(printf '%s\n' "$text" |
  gitleaks stdin --no-banner --redact -l error --exit-code 9 --report-format json --report-path - 2>/dev/null)
case $? in
  0) exit 0 ;;
  9)
    rules=$(jq -r '[.[].RuleID] | unique | join(", ")' <<<"$report" 2>/dev/null)
    hook_ask guard-sensitive "the new text in $path looks like a secret (gitleaks: ${rules:-unknown rule}); use an env var or secret store instead"
    ;;
  *) hook_ask guard-sensitive "gitleaks failed to scan the new text in $path, so it was not checked" ;;
esac
