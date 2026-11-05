#!/usr/bin/env bash
# guard-read_test.sh — table test for guard-read.sh.
#
# Why: the hook must block only a whole-file read of a large file while a
# bulk-read tool is named, and never get in the way otherwise.
# What: each row feeds a hook payload with a given environment and asserts the
# exit status (2 = block, 0 = pass). Run: bash guard-read_test.sh
set -uo pipefail

hook="$(cd "$(dirname "$0")" && pwd)/guard-read.sh"
dir=$(mktemp -d)
trap 'rm -rf "$dir"' EXIT
seq 400 >"$dir/big.txt"
seq 10 >"$dir/small.txt"

fail=0
# row <name> <want exit> <tool var> <payload>
row() {
  local got
  CLAUDE_BULK_READ_TOOL=$3 bash "$hook" <<<"$4" 2>/dev/null
  got=$?
  if [[ $got != "$2" ]]; then
    echo "FAIL $1: exit $got, want $2"
    fail=1
  else
    echo "ok   $1"
  fi
}

on="search ai read"
row "large whole read blocks" 2 "$on" "{\"tool_name\":\"Read\",\"tool_input\":{\"file_path\":\"$dir/big.txt\"}}"
row "ranged read passes" 0 "$on" "{\"tool_name\":\"Read\",\"tool_input\":{\"file_path\":\"$dir/big.txt\",\"offset\":1,\"limit\":50}}"
row "limit alone passes" 0 "$on" "{\"tool_name\":\"Read\",\"tool_input\":{\"file_path\":\"$dir/big.txt\",\"limit\":50}}"
row "small file passes" 0 "$on" "{\"tool_name\":\"Read\",\"tool_input\":{\"file_path\":\"$dir/small.txt\"}}"
row "missing file passes" 0 "$on" "{\"tool_name\":\"Read\",\"tool_input\":{\"file_path\":\"$dir/none.txt\"}}"
row "bare cat of large file blocks" 2 "$on" "{\"tool_name\":\"Bash\",\"tool_input\":{\"command\":\"cat $dir/big.txt\"}}"
row "piped cat passes" 0 "$on" "{\"tool_name\":\"Bash\",\"tool_input\":{\"command\":\"cat $dir/big.txt | head -5\"}}"
row "variable unset passes" 0 "" "{\"tool_name\":\"Read\",\"tool_input\":{\"file_path\":\"$dir/big.txt\"}}"
row "bad payload blocks" 2 "$on" "not json"
exit $fail
