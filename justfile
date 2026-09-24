# Run every test under tests/: shell tests with bash, Neovim specs headless
# inside the real config (`nvim -l` would skip init.lua).
test:
    #!/usr/bin/env bash
    set -uo pipefail
    shopt -s nullglob
    status=0
    for t in tests/*/*_test.sh; do
        echo "== $t"
        bash "$t" || status=1
    done
    # Load this checkout's nvim/ as the config (not whatever ~/.config/nvim
    # points at); plugins still come from the usual data dir.
    cfg=$(mktemp -d)
    ln -s "$PWD/nvim" "$cfg/nvim"
    for s in tests/nvim/*_spec.lua; do
        echo "== $s"
        # A spec exits via tests/lib/spec.lua's finish(); if it raises first,
        # the trailing cquit fails the run instead of leaving nvim open.
        XDG_CONFIG_HOME="$cfg" nvim --headless -c "luafile $s" -c 'cquit 1' || status=1
    done
    rm -rf "$cfg"
    exit "$status"

# Lint every shell script with shellcheck (following the sourced test libraries),
# and format-check, lint and type-check the Python hook scripts.
lint:
    shellcheck -x -P SCRIPTDIR install.sh raycast/*.sh .claude/scripts/*.sh tests/lib/*.sh tests/*/*_test.sh
    ruff format --check .claude/scripts
    ruff check .claude/scripts
    basedpyright .claude/scripts
