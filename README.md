# dotfiles

Personal config files for macOS. Nord theme throughout.

## What's included

| Directory | Description |
|-----------|-------------|
| `zsh/` | Zsh config with Powerlevel10k prompt, aliases, functions |
| `tmux/` | tmux config with Nord colors and vim-style keybindings |
| `nvim/` | Neovim (AstroNvim-based) with LSP, DAP, and 25+ plugin configs |
| `iterm/` | iTerm2 preferences and Nord color scheme |
| `raycast/` | 28 Raycast script commands for dev workflows |
| `neomutt/` | Neomutt with multi-account (Gmail + Georgia Tech OAuth2) |

## Prerequisites

- macOS
- [Homebrew](https://brew.sh)
- git, zsh, tmux, neovim, neomutt (all installable via Homebrew)
- [iTerm2](https://iterm2.com)
- [Raycast](https://raycast.com)

## Install

```bash
git clone https://github.com/alexdjalali/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

The install script is idempotent -- it backs up any existing files to
`~/.dotfiles-backup/<timestamp>/` before creating symlinks.

## Symlinks created

```
~/.zshrc                   -> ~/dotfiles/zsh/.zshrc
~/.p10k.zsh                -> ~/dotfiles/zsh/.p10k.zsh
~/.tmux.conf               -> ~/dotfiles/tmux/.tmux.conf
~/.config/nvim             -> ~/dotfiles/nvim
~/.neomuttrc               -> ~/dotfiles/neomutt/.neomuttrc
~/.neomutt                 -> ~/dotfiles/neomutt/.neomutt
~/.local/scripts/raycast   -> ~/dotfiles/raycast
```

## Post-install

1. **ZSH secrets** -- copy `zsh/.zshrc.local.example` to `zsh/.zshrc.local` and fill in API keys.
2. **Neomutt accounts** -- copy the example account files and add credentials. See `neomutt/.neomutt/QUICKSTART.md`.
3. **iTerm** -- set custom preferences folder to `~/dotfiles/iterm` in iTerm settings.
4. **Raycast** -- add `~/.local/scripts/raycast` as a Script Command directory.
