#!/usr/bin/env bash
# guard-generated.sh
#
# Claude Code PreToolUse hook for Edit and Write. It blocks a change to a
# generated file: one with a `Code generated … DO NOT EDIT` line (the Go
# convention, also written by claude-gen) among its first five lines. The
# generator would overwrite the edit on its next run, so the change belongs in
# the generator's source (template, schema, proto, wire.go).
#
# A new file (the path doesn't exist yet) is allowed. The hook fails closed:
# a payload it cannot read, or a missing jq, blocks with exit 2, the only
# status Claude Code treats as a block.
set -uo pipefail

if ! command -v jq >/dev/null 2>&1; then
  echo "BLOCKED: guard-generated.sh needs jq to read the hook payload" >&2
  exit 2
fi
if ! path=$(jq -er '.tool_input.file_path // ""'); then
  echo "BLOCKED: guard-generated.sh could not read the hook payload" >&2
  exit 2
fi
[[ -n $path && -f $path ]] || exit 0

pattern='Code generated .* DO NOT EDIT'
n=0
while ((n < 5)) && { IFS= read -r line || [[ -n $line ]]; }; do  # || keeps an unterminated last line
  n=$((n + 1))
  if [[ $line =~ $pattern ]]; then
    echo "BLOCKED: generated file — edit its source and regenerate ($path)" >&2
    exit 2
  fi
done <"$path"
exit 0
