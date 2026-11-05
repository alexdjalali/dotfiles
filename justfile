# Run every test under tests/: shell tests with bash, Neovim specs headless
# inside the real config (`nvim -l` would skip init.lua).
test:
    #!/usr/bin/env bash
    set -uo pipefail
    shopt -s nullglob
    status=0
    for t in tests/*/*_test.sh; do
        echo "== $t"
        # stdin closed: command mocks record stdin with `cat`, which blocks
        # forever when the suite runs from a non-terminal with stdin open.
        bash "$t" </dev/null || status=1
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
# format-check, lint and type-check the Python hook scripts, vet the claude-gen
# generator, and fail when a generated file differs from a fresh render.
lint:
    shellcheck -x -P SCRIPTDIR install.sh raycast/*.sh .claude/scripts/*.sh tests/lib/*.sh tests/*/*_test.sh zsh/libexec/*/*
    ruff format --check .claude/scripts
    ruff check .claude/scripts
    basedpyright .claude/scripts
    out=$(gofumpt -l .claude/gen) && test -z "$out"
    go -C .claude/gen vet ./...
    go -C .claude/gen run . --root "$PWD" --check
