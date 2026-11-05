#!/usr/bin/env bash
# guard-read.sh
#
# Claude Code PreToolUse hook for Read and Bash. When a bulk-read tool is named
# in CLAUDE_BULK_READ_TOOL (e.g. "search ai read"), it blocks reading a whole
# file of CLAUDE_BULK_READ_MIN_LINES lines or more (default 350) into context:
# a Read with neither offset nor limit, or a bare `cat <file>` command. The
# block message names the tool to ask instead, or a ranged Read.
#
# Inert when CLAUDE_BULK_READ_TOOL is unset. A ranged Read, a piped or
# compound command, a missing file and a small file pass. Once enabled it fails
# closed: a payload it cannot read, or a missing jq, blocks with exit 2, the
# only status Claude Code treats as a block.
set -uo pipefail

tool=${CLAUDE_BULK_READ_TOOL:-}
[[ -n $tool ]] || exit 0
min=${CLAUDE_BULK_READ_MIN_LINES:-350}

if ! command -v jq >/dev/null 2>&1; then
  echo "BLOCKED: guard-read.sh needs jq to read the hook payload" >&2
  exit 2
fi
if ! payload=$(cat) || ! name=$(jq -er '.tool_name // ""' <<<"$payload"); then
  echo "BLOCKED: guard-read.sh could not read the hook payload" >&2
  exit 2
fi

path=""
case $name in
  Read)
    ranged=$(jq -r '(.tool_input.offset // .tool_input.limit) != null' <<<"$payload")
    [[ $ranged == false ]] || exit 0
    path=$(jq -r '.tool_input.file_path // ""' <<<"$payload")
    ;;
  Bash)
    cmd=$(jq -r '.tool_input.command // ""' <<<"$payload")
    re='^[[:space:]]*cat[[:space:]]+([^[:space:]|;&<>]+)[[:space:]]*$'
    [[ $cmd =~ $re ]] || exit 0
    path=${BASH_REMATCH[1]}
    ;;
  *) exit 0 ;;
esac
[[ -n $path && -f $path ]] || exit 0

lines=$(wc -l <"$path" | tr -d '[:space:]')
if ((lines >= min)); then
  echo "BLOCKED: $path is $lines lines; ask \`$tool\` about it, or Read a range (offset/limit)" >&2
  exit 2
fi
exit 0
