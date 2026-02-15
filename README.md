# dotfiles

Personal dev environment for macOS. Catppuccin Mocha theme throughout.

## What's included

| Directory | Description |
|-----------|-------------|
| `zsh/` | Zsh config with Powerlevel10k prompt, aliases, functions |
| `tmux/` | tmux config with Catppuccin colors and vim-style keybindings |
| `nvim/` | Neovim (AstroNvim-based) with LSP, DAP, and 25+ plugin configs |
| `git/` | Git config with delta, GPG signing, LFS |
| `iterm/` | iTerm2 preferences and Catppuccin color scheme |
| `raycast/` | 28 Raycast script commands for dev workflows |
| `neomutt/` | Neomutt with multi-account (Gmail + Georgia Tech OAuth2) |

## Fresh machine install

The only prerequisite is macOS. The install script handles everything else:
Xcode CLT, Homebrew, all packages, shell setup, symlinks, themes, and plugins.

```bash
# On a brand-new Mac, open Terminal and run:
xcode-select --install          # if prompted, accept the dialog

git clone https://github.com/alexdjalali/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

### What the script does

1. Installs Xcode Command Line Tools (if missing)
2. Installs Homebrew (if missing)
3. Runs `brew bundle` to install all packages, casks, and fonts
4. Sets Homebrew zsh as the default shell
5. Installs Oh My Zsh, plugins (autosuggestions, syntax-highlighting, fzf-tab), and Powerlevel10k
6. Creates symlinks (with automatic backup of existing files to `~/.dotfiles-backup/`)
7. Sets up fzf shell integration (`~/.fzf.zsh`)
8. Installs bat/delta Catppuccin Mocha syntax theme
9. Downloads iTerm2 shell integration
10. Creates `~/.local/scripts`, `~/.local/docs`, `~/notes`
11. Scaffolds `~/.zshrc.local` from the example template
12. Installs TPM and tmux plugins
13. Initializes git-lfs
14. Bootstraps Neovim plugins and Treesitter parsers (headless)

The script is idempotent -- safe to run multiple times.

### Symlinks created

```
~/.gitconfig               -> ~/dotfiles/git/.gitconfig
~/.zshrc                   -> ~/dotfiles/zsh/.zshrc
~/.p10k.zsh                -> ~/dotfiles/zsh/.p10k.zsh
~/.tmux.conf               -> ~/dotfiles/tmux/.tmux.conf
~/.config/nvim             -> ~/dotfiles/nvim
~/.neomuttrc               -> ~/dotfiles/neomutt/.neomuttrc
~/.neomutt                 -> ~/dotfiles/neomutt/.neomutt
~/.local/scripts/raycast   -> ~/dotfiles/raycast
```

## Post-install (manual steps)

1. **Secrets** -- edit `~/.zshrc.local` and fill in your API keys/tokens.
2. **GPG key** -- import your existing key (`gpg --import key.asc`) or generate a new one (`gpg --full-generate-key`), then update `git/.gitconfig` signingkey if the ID changed.
3. **Neomutt** -- copy example account files and add credentials. See `neomutt/.neomutt/QUICKSTART.md`.
4. **iTerm2** -- set custom preferences folder to `~/dotfiles/iterm` in iTerm > Settings > General > Preferences.
5. **iTerm2 font** -- set font to `MesloLGS Nerd Font` in iTerm > Settings > Profiles > Text > Font.
6. **Raycast** -- add `~/.local/scripts/raycast` as a Script Command directory in Raycast preferences.
