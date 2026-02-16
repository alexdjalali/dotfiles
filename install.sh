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
err()   { printf '\033[1;31m[err]\033[0m   %s\n' "$1"; }

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
# 1. Xcode Command Line Tools
# ---------------------------------------------------------------------------

info "Checking Xcode Command Line Tools..."
if xcode-select -p &>/dev/null; then
    ok "Xcode CLT already installed"
else
    info "Installing Xcode Command Line Tools (a dialog will open)..."
    xcode-select --install
    echo "  Waiting for Xcode CLT installation to complete..."
    until xcode-select -p &>/dev/null; do
        sleep 5
    done
    ok "Xcode CLT installed"
fi

# ---------------------------------------------------------------------------
# 2. Homebrew
# ---------------------------------------------------------------------------

info "Checking Homebrew..."
if command -v brew &>/dev/null; then
    ok "Homebrew already installed"
else
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Add brew to PATH for this session
    if [ -x /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x /usr/local/bin/brew ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
    ok "Homebrew installed"
fi

# ---------------------------------------------------------------------------
# 3. Brewfile
# ---------------------------------------------------------------------------

info "Installing packages from Brewfile..."
brew bundle --file="$DOTFILES/Brewfile" --no-lock
ok "Homebrew packages installed"

# ---------------------------------------------------------------------------
# 4. Default shell
# ---------------------------------------------------------------------------

BREW_ZSH="$(brew --prefix)/bin/zsh"
if [ "$SHELL" = "$BREW_ZSH" ]; then
    ok "Default shell is already Homebrew zsh"
else
    info "Setting default shell to Homebrew zsh..."
    if ! grep -qF "$BREW_ZSH" /etc/shells; then
        echo "$BREW_ZSH" | sudo tee -a /etc/shells >/dev/null
    fi
    sudo chsh -s "$BREW_ZSH" "$USER"
    ok "Default shell set to $BREW_ZSH"
fi

# ---------------------------------------------------------------------------
# 5. Oh My Zsh + Custom Plugins
# ---------------------------------------------------------------------------

info "Setting up Oh My Zsh..."
if [ -d "$HOME/.oh-my-zsh" ]; then
    ok "Oh My Zsh already installed"
else
    RUNZSH=no KEEP_ZSHRC=yes \
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    ok "Oh My Zsh installed"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

clone_if_missing() {
    local repo="$1"
    local dest="$ZSH_CUSTOM/plugins/$(basename "$repo")"
    if [ -d "$dest" ]; then
        ok "Plugin $(basename "$repo") already installed"
    else
        git clone "https://github.com/$repo" "$dest"
        ok "Plugin $(basename "$repo") installed"
    fi
}

clone_if_missing zsh-users/zsh-autosuggestions
clone_if_missing zsh-users/zsh-syntax-highlighting
clone_if_missing Aloxaf/fzf-tab

# Powerlevel10k (via Oh My Zsh custom themes — not the Homebrew version)
P10K_DIR="$ZSH_CUSTOM/themes/powerlevel10k"
if [ -d "$P10K_DIR" ]; then
    ok "Powerlevel10k already installed"
else
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
    ok "Powerlevel10k installed"
fi

# ---------------------------------------------------------------------------
# 6. Symlinks
# ---------------------------------------------------------------------------

info "Installing dotfiles symlinks..."

backup_and_link "$DOTFILES/git/.gitconfig"       "$HOME/.gitconfig"
backup_and_link "$DOTFILES/zsh/.zshrc"          "$HOME/.zshrc"
backup_and_link "$DOTFILES/zsh/.p10k.zsh"       "$HOME/.p10k.zsh"
backup_and_link "$DOTFILES/tmux/.tmux.conf"     "$HOME/.tmux.conf"
backup_and_link "$DOTFILES/nvim"                "$HOME/.config/nvim"
backup_and_link "$DOTFILES/neomutt/.neomuttrc"  "$HOME/.neomuttrc"
backup_and_link "$DOTFILES/neomutt/.neomutt"    "$HOME/.neomutt"
backup_and_link "$DOTFILES/raycast"             "$HOME/.local/scripts/raycast"

# Claude Code (individual files — ~/.claude/ also contains runtime data we don't track)
backup_and_link "$DOTFILES/.claude/CLAUDE.md"           "$HOME/.claude/CLAUDE.md"
backup_and_link "$DOTFILES/.claude/settings.json"       "$HOME/.claude/settings.json"
backup_and_link "$DOTFILES/.claude/settings.local.json" "$HOME/.claude/settings.local.json"
backup_and_link "$DOTFILES/.claude/commands"             "$HOME/.claude/commands"

# Cursor (global rules and skills — ~/.cursor/ also contains runtime data we don't track)
backup_and_link "$DOTFILES/cursor/rules"                "$HOME/.cursor/rules"
backup_and_link "$DOTFILES/cursor/skills-cursor"        "$HOME/.cursor/skills-cursor"

# ---------------------------------------------------------------------------
# 7. fzf shell integration
# ---------------------------------------------------------------------------

info "Setting up fzf shell integration..."
if [ -f "$HOME/.fzf.zsh" ]; then
    ok "fzf shell integration already installed"
else
    FZF_PREFIX="$(brew --prefix)/opt/fzf"
    if [ -x "$FZF_PREFIX/install" ]; then
        "$FZF_PREFIX/install" --key-bindings --completion --no-update-rc --no-bash --no-fish
        ok "fzf shell integration installed"
    else
        warn "fzf install script not found — run 'fzf --version' to verify installation"
    fi
fi

# ---------------------------------------------------------------------------
# 8. Bat Catppuccin theme (also used by delta)
# ---------------------------------------------------------------------------

info "Setting up bat Catppuccin Mocha theme..."
BAT_THEME_DIR="$(bat --config-dir)/themes"
BAT_THEME_FILE="$BAT_THEME_DIR/Catppuccin Mocha.tmTheme"
if [ -f "$BAT_THEME_FILE" ]; then
    ok "Bat Catppuccin Mocha theme already installed"
else
    mkdir -p "$BAT_THEME_DIR"
    curl -fsSL \
      "https://raw.githubusercontent.com/catppuccin/bat/main/themes/Catppuccin%20Mocha.tmTheme" \
      -o "$BAT_THEME_FILE"
    bat cache --build
    ok "Bat Catppuccin Mocha theme installed (also used by delta)"
fi

# ---------------------------------------------------------------------------
# 9. iTerm2 shell integration
# ---------------------------------------------------------------------------

info "Setting up iTerm2 shell integration..."
ITERM_INTEGRATION="$HOME/.iterm2_shell_integration.zsh"
if [ -f "$ITERM_INTEGRATION" ]; then
    ok "iTerm2 shell integration already installed"
else
    curl -fsSL "https://iterm2.com/shell_integration/zsh" -o "$ITERM_INTEGRATION"
    ok "iTerm2 shell integration installed"
fi

# ---------------------------------------------------------------------------
# 10. Create expected directories
# ---------------------------------------------------------------------------

info "Creating expected directories..."
mkdir -p "$HOME/.local/scripts"
mkdir -p "$HOME/.local/docs"
mkdir -p "$HOME/notes"
ok "Created ~/.local/scripts, ~/.local/docs, ~/notes"

# ---------------------------------------------------------------------------
# 11. Scaffold ~/.zshrc.local
# ---------------------------------------------------------------------------

info "Checking ~/.zshrc.local..."
if [ -f "$HOME/.zshrc.local" ]; then
    ok "~/.zshrc.local already exists"
else
    cp "$DOTFILES/zsh/.zshrc.local.example" "$HOME/.zshrc.local"
    ok "Scaffolded ~/.zshrc.local from example — edit it to add your secrets"
fi

# ---------------------------------------------------------------------------
# 12. Tmux Plugin Manager + plugins
# ---------------------------------------------------------------------------

info "Setting up Tmux Plugin Manager..."
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ -d "$TPM_DIR" ]; then
    ok "TPM already installed"
else
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
    ok "TPM installed"
fi

info "Installing tmux plugins..."
if [ -x "$TPM_DIR/bin/install_plugins" ]; then
    "$TPM_DIR/bin/install_plugins"
    ok "Tmux plugins installed"
else
    warn "TPM install_plugins script not found — run 'prefix + I' inside tmux"
fi

# ---------------------------------------------------------------------------
# 13. git-lfs
# ---------------------------------------------------------------------------

info "Setting up git-lfs..."
if command -v git-lfs &>/dev/null; then
    git lfs install --skip-smudge
    ok "git-lfs initialized"
else
    warn "git-lfs not found — check Brewfile installation"
fi

# ---------------------------------------------------------------------------
# 14. Neovim headless bootstrap
# ---------------------------------------------------------------------------

info "Bootstrapping Neovim plugins (headless)..."
if command -v nvim &>/dev/null; then
    nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
    ok "Neovim plugins synced"
    info "Installing Treesitter parsers (this may take a moment)..."
    nvim --headless "+TSUpdateSync" +qa 2>/dev/null || true
    ok "Treesitter parsers installed"
else
    warn "Neovim not found — skipping plugin bootstrap"
fi

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------

echo ""
echo "==========================================================="
info "Installation complete!"
echo "==========================================================="
echo ""
echo "  Remaining manual steps:"
echo ""
echo "  1. SECRETS: Edit ~/.zshrc.local and add your API keys/tokens."
echo ""
echo "  2. GPG KEY: Import your GPG key for git commit signing:"
echo "       gpg --import /path/to/private-key.asc"
echo "     Or generate a new one:"
echo "       gpg --full-generate-key"
echo "     Then update git/.gitconfig [user] signingkey with the new ID."
echo ""
echo "  3. NEOMUTT: Copy example account files and add credentials:"
echo "       See neomutt/.neomutt/QUICKSTART.md"
echo ""
echo "  4. ITERM2: Set custom preferences folder in:"
echo "       iTerm > Settings > General > Preferences -> $DOTFILES/iterm"
echo ""
echo "  5. RAYCAST: Add ~/.local/scripts/raycast as a Script Command"
echo "     directory in Raycast preferences."
echo ""
echo "  6. FONT: Set your terminal font to 'MesloLGS Nerd Font' in"
echo "     iTerm > Settings > Profiles > Text > Font."
echo ""
echo "  7. CLAUDE CODE: Review ~/.claude/settings.local.json for"
echo "     machine-specific permissions. Runtime data (sessions,"
echo "     cache, history) stays in ~/.claude/ untracked."
echo ""
echo "  8. CURSOR: Global rules are symlinked to ~/.cursor/rules/."
echo "     Project rules go in each repo's .cursor/rules/ dir."
echo ""
echo "  9. Open a new shell to pick up all changes."
echo ""
