#!/usr/bin/env bash
# sync-mirrors.sh [--check] [DIR]
#
# Regenerates kilocode/rules/*.md from cursor/rules/*.mdc. The Cursor rules are
# the condensed, hand-edited mirror of the Claude Code rules in .claude/ (which
# stays the source of truth; the source -> mirror table is in
# cursor/rules/global-standards.mdc). This script automates the second hop only:
# each Kilocode rule is its Cursor rule without the frontmatter, with
# typescript-react.mdc named typescript.md, and the rule-file references in
# global-standards (`python.mdc` (`.py` files)) pointing at the .md names.
#
#   DIR      the dotfiles checkout (default: the repo holding this script)
#   --check  write nothing; exit 1 listing each Kilocode rule that differs from
#            its Cursor source or has none (generating deletes those orphans)
set -euo pipefail

# The Kilocode file name for a Cursor rule path.
kilocode_name() {
    local name
    name=$(basename "$1" .mdc)
    [[ $name == typescript-react ]] && name=typescript
    echo "$name.md"
}

# A Cursor rule's body as Kilocode reads it.
# shellcheck disable=SC2016  # the sed backticks are literal Markdown
render() {
    awk 'NR == 1 && /^---$/ { fm = 1; next }
         fm && /^---$/ { fm = 0; after = 1; next }
         fm { next }
         after && /^$/ { after = 0; next }
         { after = 0; print }' "$1" |
        sed -E 's/`([a-z-]+)\.mdc` \([^)]*files\)/`\1.md`/g; s/`typescript-react\.md`/`typescript.md`/g'
}

check=false
if [[ ${1:-} == --check ]]; then
    check=true
    shift
fi
root=${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}

drift=()
expected=()
for src in "$root"/cursor/rules/*.mdc; do
    dst="$root/kilocode/rules/$(kilocode_name "$src")"
    expected+=("$dst")
    if $check; then
        render "$src" | cmp -s - "$dst" || drift+=("kilocode/rules/$(basename "$dst")")
    else
        render "$src" > "$dst"
    fi
done
for dst in "$root"/kilocode/rules/*.md; do
    [[ " ${expected[*]} " == *" $dst "* ]] && continue
    if $check; then
        drift+=("kilocode/rules/$(basename "$dst") (no Cursor source)")
    else
        rm "$dst"
    fi
done

if ((${#drift[@]})); then
    printf 'out of sync with cursor/rules: %s\n' "${drift[@]}" >&2
    echo "run .claude/scripts/sync-mirrors.sh to regenerate kilocode/rules" >&2
    exit 1
fi
