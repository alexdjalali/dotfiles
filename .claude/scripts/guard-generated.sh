#!/usr/bin/env bash
# guard-generated.sh
#
# Claude Code PreToolUse hook for Edit and Write. A change to a generated
# file goes to the user's permission prompt (an "ask" decision, hook_lib.sh): one with a `Code generated … DO NOT EDIT` line (the Go
# convention, also written by claude-gen) among its first five lines. The
# generator would overwrite the edit on its next run, so the change belongs in
# the generator's source (template, schema, proto, wire.go).
#
# A new file (the path doesn't exist yet) is allowed. The hook fails toward
# the prompt: a payload it cannot read, or a missing jq, asks.
set -uo pipefail

here=${BASH_SOURCE[0]%/*}
[[ $here == "${BASH_SOURCE[0]}" ]] && here=.
# shellcheck source=hook_lib.sh
source "$here/hook_lib.sh" || exit 2

payload=""
hook_payload guard-generated payload
path=$(jq -r '.tool_input.file_path // ""' <<<"$payload")
[[ -n $path && -f $path ]] || exit 0

pattern='Code generated .* DO NOT EDIT'
n=0
while ((n < 5)) && { IFS= read -r line || [[ -n $line ]]; }; do  # || keeps an unterminated last line
  n=$((n + 1))
  if [[ $line =~ $pattern ]]; then
    hook_ask guard-generated "generated file; edit its source and regenerate ($path)"
  fi
done <"$path"
exit 0
