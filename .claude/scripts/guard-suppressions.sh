#!/usr/bin/env bash
# guard-suppressions.sh
#
# Claude Code PreToolUse hook for Edit and Write. A change that silences a
# check instead of satisfying it goes to the user's permission prompt (an
# "ask" decision, hook_lib.sh), where the user's approval is the override:
#   - in a code file, a new inline suppression (//nolint, #nosec, nosemgrep,
#     # noqa, type: ignore, pyright: ignore, eslint-disable, @ts-ignore,
#     @ts-expect-error, //lint:ignore, pylint: disable, istanbul/c8 ignore);
#   - an exemption, baseline or allowlist file that gains lines.
# A marker counts only when the new text holds more of it than the old text
# (old_string for Edit, the file on disk for Write), so moving or deleting an
# existing suppression passes. A rule that is wrong is changed by the user
# (or by an ADR), never by an agent-written exception.
#
# The hook fails toward the prompt: a payload it cannot read, or a missing
# jq, asks.
set -uo pipefail

here=${BASH_SOURCE[0]%/*}
[[ $here == "${BASH_SOURCE[0]}" ]] && here=.
# shellcheck source=hook_lib.sh
source "$here/hook_lib.sh" || exit 2

# block <what>: ask the user about the change, naming the alternative.
block() {
  hook_ask guard-suppressions "$1 ($path). Do not silence the check: fix the code so it passes. If the rule itself is wrong, stop and propose the rule change (ADR) to the user; exceptions are added by the user, not by an agent."
}

full=""
hook_payload guard-suppressions full
payload=$(jq -c '.tool_input // {}' <<<"$full")
path=$(jq -r '.file_path // ""' <<<"$payload")
[[ -n $path ]] || exit 0

new=$(jq -r '.new_string // .content // ""' <<<"$payload")
if jq -e 'has("old_string")' <<<"$payload" >/dev/null; then
  old=$(jq -r '.old_string' <<<"$payload")
elif [[ -f $path ]]; then
  old=$(cat "$path")
else
  old=""
fi

# Count of lines in $1 that are not blank.
lines() { printf '%s\n' "$1" | grep -c '[^[:space:]]'; }
# Count of matches of the ERE $2 in $1.
matches() { printf '%s\n' "$1" | grep -oE -- "$2" | wc -l | tr -d ' '; }

base=$(basename "$path")
shopt -s nocasematch
case "$base" in
  *exempt* | *baseline* | *allowlist* | *allow-list* | .trivyignore | .semgrepignore | .eslintignore | *trivy*ignore*)
    if (($(lines "$new") > $(lines "$old"))); then
      block "exemption file grows"
    fi
    exit 0
    ;;
esac
shopt -u nocasematch

case "$path" in
  *.go | *.py | *.pyi | *.ts | *.tsx | *.js | *.jsx | *.mjs | *.cjs) ;;
  *) exit 0 ;;
esac

markers='//[[:space:]]*nolint|#nosec|//[[:space:]]*#?nosec|#[[:space:]]+nosec|nosemgrep|#[[:space:]]*noqa|type:[[:space:]]*ignore|pyright:[[:space:]]*ignore|eslint-disable|@ts-ignore|@ts-expect-error|//lint:ignore|pylint:[[:space:]]*disable|istanbul ignore|c8 ignore'
if (($(matches "$new" "$markers") > $(matches "$old" "$markers"))); then
  block "new inline suppression"
fi
exit 0
