#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$HOME/dotfiles"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

info()  { printf '\033[1;34m[info]\033[0m  %s\n' "$1"; }
ok()    { printf '\033[1;32m[ok]\033[0m    %s\n' "$1"; }
warn()  { printf '\033[1;33m[warn]\033[0m  %s\n' "$1"; }

backup_and_link() {
    local src="$1" dst="$2"

    # If destination already points to the right place, skip
    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
        ok "$dst -> $src (already linked)"
        return
    fi

    # Back up existing file/symlink/directory
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        mkdir -p "$BACKUP_DIR"
        mv "$dst" "$BACKUP_DIR/"
        warn "Backed up $dst -> $BACKUP_DIR/"
    fi

    # Ensure parent directory exists
    mkdir -p "$(dirname "$dst")"

    ln -s "$src" "$dst"
    ok "$dst -> $src"
}

# ---------------------------------------------------------------------------
# Symlinks
# ---------------------------------------------------------------------------

info "Installing dotfiles symlinks..."

backup_and_link "$DOTFILES/zsh/.zshrc"          "$HOME/.zshrc"
backup_and_link "$DOTFILES/zsh/.p10k.zsh"       "$HOME/.p10k.zsh"
backup_and_link "$DOTFILES/tmux/.tmux.conf"     "$HOME/.tmux.conf"
backup_and_link "$DOTFILES/nvim"                "$HOME/.config/nvim"
backup_and_link "$DOTFILES/neomutt/.neomuttrc"  "$HOME/.neomuttrc"
backup_and_link "$DOTFILES/neomutt/.neomutt"    "$HOME/.neomutt"
backup_and_link "$DOTFILES/raycast"             "$HOME/.local/scripts/raycast"

# ---------------------------------------------------------------------------
# Post-install reminders
# ---------------------------------------------------------------------------

echo ""
info "Done! Post-install reminders:"
echo ""
echo "  0. Install Homebrew dependencies:"
echo "     brew bundle --file=$DOTFILES/Brewfile"
echo ""
echo "  1. ZSH secrets: copy zsh/.zshrc.local.example to zsh/.zshrc.local"
echo "     and fill in API keys / tokens."
echo ""
echo "  2. Neomutt accounts: copy the example files into .neomutt/ and fill"
echo "     in credentials (account.gmail, account.gatech, *.pass, *.tokens)."
echo ""
echo "  3. iTerm preferences: set custom folder in iTerm > Settings >"
echo "     General > Preferences to: $DOTFILES/iterm"
echo ""
echo "  4. Raycast scripts: add $HOME/.local/scripts/raycast as a"
echo "     Script Command directory in Raycast preferences."
echo ""
echo "  5. Tmux plugins: install TPM and plugins:"
echo "     git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm"
echo "     tmux source ~/.tmux.conf  # then press prefix + I to install plugins"
echo ""
