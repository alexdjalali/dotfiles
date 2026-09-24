#!/usr/bin/env bash
# Tests that keep README.md in step with install.sh and the Brewfile. Text
# parsing only: install.sh is read, never run.
# shellcheck disable=SC2016  # sed patterns match a literal $DOTFILES/$HOME
set -uo pipefail
# shellcheck source=../lib/assert.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/assert.sh"

README="$REPO_ROOT/README.md"
INSTALL="$REPO_ROOT/install.sh"

# The lines of README.md between a "### $1" heading and the next heading.
readme_section() {
  awk -v h="### $1" '$0 == h {on = 1; next} on && /^#/ {exit} on' "$README"
}

# Why this test is important:
#   - The symlink list is how a reader learns what install.sh will overwrite in
#     their home directory; it listed a removed link and missed seven.
# What it tests:
#   - The "Symlinks created" block holds exactly the backup_and_link pairs.
test_symlink_table_matches_install() {
  local want got
  want=$(sed -nE 's/^ *backup_and_link "\$DOTFILES\/([^"]+)" +"\$HOME\/([^"]+)".*/~\/\2 -> ~\/dotfiles\/\1/p' "$INSTALL" | sort)
  got=$(readme_section "Symlinks created" | grep -- '->' | sed -E 's/ +-> +/ -> /' | sort)
  [[ -n "$want" ]] || _fail "no backup_and_link calls parsed from install.sh"
  assert_eq "$want" "$got" "README symlinks vs install.sh"
}

# Why this test is important:
#   - The numbered step list drifted from the script (a removed step, a missing one).
# What it tests:
#   - "What the script does" has one entry per `# N. Title` step header in
#     install.sh, in order: entry N names the first word of header N.
test_step_list_matches_install_headers() {
  local headers entries i header entry word
  headers=$(sed -nE 's/^# ([0-9]+)\. (.*)/\2/p' "$INSTALL")
  entries=$(readme_section "What the script does" | sed -nE 's/^[0-9]+\. (.*)/\1/p')
  assert_eq "$(wc -l <<<"$headers")" "$(wc -l <<<"$entries")" "README steps vs install.sh step headers"
  for ((i = 1; i <= $(wc -l <<<"$headers"); i++)); do
    header=$(sed -n "${i}p" <<<"$headers")
    entry=$(sed -n "${i}p" <<<"$entries")
    word=${header%% *}
    grep -qiF -- "$word" <<<"$entry" || _fail "step $i: README [$entry] doesn't mention [$word] from [$header]"
  done
}

# Why this test is important:
#   - The hand-kept tool tables disagreed with the Brewfile; the README now
#     names only a core set and points at the Brewfile for the rest.
# What it tests:
#   - Every formula on the README's "Core tools" line is an uncommented
#     `brew "…"` entry in the Brewfile.
test_named_formulae_exist_in_brewfile() {
  local line tool missing=()
  line=$(grep '^\*\*Core tools:\*\*' "$README") || _fail "no **Core tools:** line in README.md"
  for tool in $(grep -oE '`[^`]+`' <<<"$line" | tr -d '`'); do
    grep -qE "^brew \"$tool\"" "$REPO_ROOT/Brewfile" || missing+=("$tool")
  done
  assert_eq "" "${missing[*]-}" "core tools not installed by the Brewfile"
}

run_test test_symlink_table_matches_install
run_test test_step_list_matches_install_headers
run_test test_named_formulae_exist_in_brewfile
finish
