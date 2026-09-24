#!/usr/bin/env bash
# install.sh [--update]
#
# Bootstraps this dotfiles repo on macOS. --update skips the install steps
# (1-5) and re-syncs links, themes and tools. Each numbered step is a function
# and main runs them in order; sourcing the file (as tests/install/ does) only
# defines them.

# The repo is wherever this script lives.
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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
# 1. Xcode Command Line Tools (skip with --update)
# ---------------------------------------------------------------------------

install_xcode_clt() {
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
}

# ---------------------------------------------------------------------------
# 2. Homebrew
# ---------------------------------------------------------------------------

install_homebrew() {
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
}

# ---------------------------------------------------------------------------
# 3. Brewfile
# ---------------------------------------------------------------------------

install_brewfile() {
    info "Installing packages from Brewfile..."
    if brew bundle --file="$DOTFILES/Brewfile"; then
        ok "Homebrew packages installed"
    else
        warn "Some Brewfile entries failed — check output above"
        warn "Continuing with the rest of the install..."
    fi
}

# ---------------------------------------------------------------------------
# 4. Default shell
# ---------------------------------------------------------------------------

set_default_shell() {
    local BREW_ZSH
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
}

# ---------------------------------------------------------------------------
# 5. Oh My Zsh + Custom Plugins
# ---------------------------------------------------------------------------

clone_if_missing() {
    local repo="$1" dest
    dest="$ZSH_CUSTOM/plugins/$(basename "$repo")"
    if [ -d "$dest" ]; then
        ok "Plugin $(basename "$repo") already installed"
    else
        git clone "https://github.com/$repo" "$dest"
        ok "Plugin $(basename "$repo") installed"
    fi
}

install_oh_my_zsh() {
    info "Setting up Oh My Zsh..."
    if [ -d "$HOME/.oh-my-zsh" ]; then
        ok "Oh My Zsh already installed"
    else
        RUNZSH=no KEEP_ZSHRC=yes \
          sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        ok "Oh My Zsh installed"
    fi

    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    clone_if_missing zsh-users/zsh-autosuggestions
    clone_if_missing zsh-users/zsh-syntax-highlighting
    clone_if_missing Aloxaf/fzf-tab

    # Powerlevel10k (via Oh My Zsh custom themes — not the Homebrew version)
    local P10K_DIR="$ZSH_CUSTOM/themes/powerlevel10k"
    if [ -d "$P10K_DIR" ]; then
        ok "Powerlevel10k already installed"
    else
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
        ok "Powerlevel10k installed"
    fi
}

# ---------------------------------------------------------------------------
# 6. Symlinks
# ---------------------------------------------------------------------------

link_dotfiles() {
    info "Installing dotfiles symlinks..."

    backup_and_link "$DOTFILES/git/.gitconfig"       "$HOME/.gitconfig"
    backup_and_link "$DOTFILES/zsh/.zshrc"          "$HOME/.zshrc"
    backup_and_link "$DOTFILES/zsh/.p10k.zsh"       "$HOME/.p10k.zsh"
    backup_and_link "$DOTFILES/tmux/.tmux.conf"     "$HOME/.tmux.conf"
    backup_and_link "$DOTFILES/nvim"                "$HOME/.config/nvim"
    backup_and_link "$DOTFILES/neomutt/.neomuttrc"  "$HOME/.neomuttrc"
    backup_and_link "$DOTFILES/neomutt/.neomutt"    "$HOME/.neomutt"
    backup_and_link "$DOTFILES/raycast"             "$HOME/.local/scripts/raycast"

    # Ensure Raycast scripts are executable
    chmod +x "$DOTFILES/raycast/"*.sh 2>/dev/null || true

    # Claude Code (individual files — ~/.claude/ also contains runtime data we don't track)
    backup_and_link "$DOTFILES/.claude/CLAUDE.md"           "$HOME/.claude/CLAUDE.md"
    backup_and_link "$DOTFILES/.claude/RTK.md"             "$HOME/.claude/RTK.md"
    backup_and_link "$DOTFILES/.claude/settings.json"       "$HOME/.claude/settings.json"
    # settings.local.json is machine-specific (not tracked in git) — scaffold if missing
    if [ ! -f "$HOME/.claude/settings.local.json" ]; then
        mkdir -p "$HOME/.claude"
        printf '{\n  "permissions": {\n    "allow": []\n  }\n}\n' > "$HOME/.claude/settings.local.json"
        ok "Scaffolded ~/.claude/settings.local.json — edit to add local permissions"
    else
        # shellcheck disable=SC2088  # display text, not a path
        ok "~/.claude/settings.local.json already exists"
    fi
    backup_and_link "$DOTFILES/.claude/skills"               "$HOME/.claude/skills"
    backup_and_link "$DOTFILES/.claude/templates"            "$HOME/.claude/templates"
    backup_and_link "$DOTFILES/.claude/rules"                "$HOME/.claude/rules"
    backup_and_link "$DOTFILES/.claude/agents"               "$HOME/.claude/agents"

    # Cursor (global rules — ~/.cursor/ also holds runtime data and the skills Cursor manages itself)
    backup_and_link "$DOTFILES/cursor/rules"                "$HOME/.cursor/rules"

    # Kilocode (global rules)
    backup_and_link "$DOTFILES/kilocode/rules"              "$HOME/.kilocode/rules"

    remove_legacy_links
}

# Links older layouts made: skills used to live in ~/.claude/commands, the rules
# in ~/.claude/standards, and Cursor now manages ~/.cursor/skills-cursor itself.
remove_legacy_links() {
    local link
    for link in "$HOME/.claude/commands" "$HOME/.claude/standards" "$HOME/.cursor/skills-cursor"; do
        if [ -L "$link" ]; then
            rm "$link"
            ok "Removed legacy link $link"
        fi
    done
}

# ---------------------------------------------------------------------------
# 7. Bat Catppuccin theme (also used by delta)
# ---------------------------------------------------------------------------

setup_bat_theme() {
    info "Setting up bat Catppuccin Mocha theme..."
    if ! command -v bat &>/dev/null; then
        warn "bat not found — skipping its Catppuccin theme (check Brewfile installation)"
        return
    fi
    local BAT_THEME_DIR BAT_THEME_FILE
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
}

# ---------------------------------------------------------------------------
# 8. iTerm2 shell integration
# ---------------------------------------------------------------------------

setup_iterm_integration() {
    info "Setting up iTerm2 shell integration..."
    local ITERM_INTEGRATION="$HOME/.iterm2_shell_integration.zsh"
    if [ -f "$ITERM_INTEGRATION" ]; then
        ok "iTerm2 shell integration already installed"
    else
        curl -fsSL "https://iterm2.com/shell_integration/zsh" -o "$ITERM_INTEGRATION"
        ok "iTerm2 shell integration installed"
    fi
}

# ---------------------------------------------------------------------------
# 9. Create expected directories
# ---------------------------------------------------------------------------

create_directories() {
    info "Creating expected directories..."
    mkdir -p "$HOME/.local/scripts"
    mkdir -p "$HOME/.local/docs"
    mkdir -p "$HOME/notes"
    # neomutt cache lives outside the repo (headers is a single file neomutt
    # creates): see neomutt/.neomuttrc
    mkdir -p "$HOME/.cache/neomutt/bodies" "$HOME/.cache/neomutt/tmp"
    chmod 700 "$HOME/.cache/neomutt"
    ok "Created ~/.local/scripts, ~/.local/docs, ~/notes, ~/.cache/neomutt"
}

# ---------------------------------------------------------------------------
# 10. Scaffold ~/.zshrc.local
# ---------------------------------------------------------------------------

scaffold_zshrc_local() {
    info "Checking ~/.zshrc.local..."
    if [ -f "$HOME/.zshrc.local" ]; then
        # shellcheck disable=SC2088  # display text, not a path
        ok "~/.zshrc.local already exists"
    else
        cp "$DOTFILES/zsh/.zshrc.local.example" "$HOME/.zshrc.local"
        ok "Scaffolded ~/.zshrc.local from example — edit it to add your secrets"
    fi
}

# ---------------------------------------------------------------------------
# 11. Tmux Plugin Manager + plugins
# ---------------------------------------------------------------------------

setup_tmux_plugins() {
    info "Setting up Tmux Plugin Manager..."
    local TPM_DIR="$HOME/.tmux/plugins/tpm"
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
}

# ---------------------------------------------------------------------------
# 12. git-lfs
# ---------------------------------------------------------------------------

setup_git_lfs() {
    info "Setting up git-lfs..."
    if command -v git-lfs &>/dev/null; then
        # Plain install: writes exactly the [filter "lfs"] git/.gitconfig tracks.
        git lfs install
        ok "git-lfs initialized"
    else
        warn "git-lfs not found — check Brewfile installation"
    fi
}

# ---------------------------------------------------------------------------
# 13. LaTeX setup (latexmkrc + Skim inverse search)
# ---------------------------------------------------------------------------

setup_latex() {
    info "Setting up LaTeX environment..."
    if command -v latexmk &>/dev/null || [ -x /Library/TeX/texbin/latexmk ]; then
        # Ensure TeX binaries are on PATH for this session
        if [ -d /Library/TeX/texbin ] && ! command -v latexmk &>/dev/null; then
            export PATH="/Library/TeX/texbin:$PATH"
        fi

        # Install latexmkrc (optimized build config)
        backup_and_link "$DOTFILES/latex/.latexmkrc" "$HOME/.latexmkrc"

        # Configure Skim inverse search for Neovim
        if [ -d "/Applications/Skim.app" ]; then
            defaults write -app Skim SKTeXEditorPreset -string "Custom"
            defaults write -app Skim SKTeXEditorCommand -string "nvim"
            defaults write -app Skim SKTeXEditorArguments -string "--headless -c \"VimtexInverseSearch %line '%file'\""
            ok "Skim inverse search configured for Neovim"
        else
            warn "Skim not found — install it for PDF preview with SyncTeX"
        fi
        ok "LaTeX environment configured"
    else
        warn "MacTeX not found — LaTeX features unavailable (install via: brew install --cask mactex)"
    fi
}

# ---------------------------------------------------------------------------
# 14. Neovim headless bootstrap
# ---------------------------------------------------------------------------

# Run headless Neovim commands. nvim exits 0 even when a -c command fails
# (E492, a Lua error), so exit 1 whenever one left an error message.
nvim_headless() {
    nvim --headless "$@" -c 'if v:errmsg != "" | cquit 1 | endif' -c 'qa'
}

bootstrap_nvim() {
    info "Installing Neovim plugins at their lazy-lock.json versions (headless)..."
    if ! command -v nvim &>/dev/null; then
        warn "Neovim not found — skipping plugin bootstrap"
        return
    fi
    if nvim_headless -c 'Lazy! restore'; then
        ok "Neovim plugins restored from lazy-lock.json"
    else
        warn "Neovim plugin restore failed — open nvim and run :Lazy to see why"
    fi
    info "Installing Treesitter parsers (this may take a moment)..."
    if nvim_headless -c 'lua require("nvim-treesitter").update():wait(600000)'; then
        ok "Treesitter parsers installed"
    else
        warn "Treesitter parser install failed — open nvim and run :TSUpdate"
    fi
}

# ---------------------------------------------------------------------------
# 15. Python CLI tools (uv) — isolated per-tool virtualenvs
# ---------------------------------------------------------------------------

install_uv_tools() {
    # Standalone `uv tool` installs, one isolated venv each, of the Python tools
    # used outside a project venv: `just lint` (ruff, basedpyright), the Claude
    # Code format hook (ruff), and Neovim when a repo has no .venv. Runs in both
    # fresh and --update modes.
    info "Installing Python CLI tools via uv..."
    if command -v uv &>/dev/null; then
        for tool in basedpyright ruff; do
            if uv tool list 2>/dev/null | grep -q "^${tool} "; then
                ok "uv tool '$tool' already installed"
            else
                if uv tool install "$tool"; then
                    ok "uv tool '$tool' installed"
                else
                    warn "uv tool '$tool' failed to install"
                fi
            fi
        done
    else
        warn "uv not found — skipping Python CLI tools (check Brewfile)"
    fi
}

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------

print_next_steps() {
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
    echo "     Then set [user] signingkey (and any other per-machine git settings)"
    echo "     in ~/.gitconfig.local, which git/.gitconfig includes last."
    echo ""
    echo "  3. NEOMUTT: Copy the example account file and add credentials:"
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
    echo "  9. KILOCODE: Global rules are symlinked to ~/.kilocode/rules/."
    echo ""
    echo " 10. Open a new shell to pick up all changes."
    echo ""
    echo "  TIP: Run './install.sh --update' to re-sync symlinks without"
    echo "       reinstalling packages."
    echo ""
}

main() {
    if [[ "$DOTFILES" != "$HOME/dotfiles" ]]; then
        warn "Running from $DOTFILES: .claude/settings.json hook paths and zsh's DOTFILES default assume ~/dotfiles"
    fi
    if [[ "${1:-}" == "--update" ]]; then
        info "Update mode: skipping install steps 1-5, jumping to symlinks..."
    else
        install_xcode_clt
        install_homebrew
        install_brewfile
        set_default_shell
        install_oh_my_zsh
    fi
    link_dotfiles
    setup_bat_theme
    setup_iterm_integration
    create_directories
    scaffold_zshrc_local
    setup_tmux_plugins
    setup_git_lfs
    setup_latex
    bootstrap_nvim
    install_uv_tools
    print_next_steps
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    set -euo pipefail
    main "$@"
fi
