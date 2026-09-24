# dotfiles

Personal dev environment for macOS. Catppuccin Mocha theme throughout.

## What's included

| Directory | Description |
|-----------|-------------|
| `zsh/` | Zsh config with Powerlevel10k prompt, aliases, functions |
| `tmux/` | tmux config with Catppuccin colors and vim-style keybindings |
| `nvim/` | Neovim (AstroNvim-based) with LSP, DAP, and 30+ plugin configs |
| `latex/` | LaTeX config (latexmkrc with build optimizations) |
| `git/` | Git config with delta, GPG signing, LFS |
| `iterm/` | iTerm2 preferences and Catppuccin color scheme |
| `raycast/` | 28 Raycast script commands for dev workflows |
| `neomutt/` | Neomutt for Gmail (password in the macOS Keychain) |
| `Brewfile` | Homebrew packages, casks and fonts (annotated; commented entries are optional) |
| `.claude/` | Claude Code config: CLAUDE.md, rules, skills, templates, agents, hook scripts, settings |
| `cursor/` | Cursor global rules (a condensed mirror of the Claude rules) |
| `kilocode/` | Kilocode global rules, generated from `cursor/rules/` |
| `tests/`, `justfile` | `just test` and `just lint` for the scripts and config |

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
3. Installs the Brewfile's packages, casks, and fonts (`brew bundle`)
4. Sets Homebrew zsh as the default shell
5. Installs Oh My Zsh, plugins (autosuggestions, syntax-highlighting, fzf-tab), and Powerlevel10k
6. Creates symlinks (with automatic backup of existing files to `~/.dotfiles-backup/`) and removes links older versions made
7. Installs the bat/delta Catppuccin Mocha syntax theme (skipped with a warning if bat is missing)
8. Downloads iTerm2 shell integration
9. Creates `~/.local/scripts`, `~/.local/docs`, `~/notes`, `~/.cache/neomutt`
10. Scaffolds `~/.zshrc.local` from the example template
11. Installs TPM and tmux plugins
12. Initializes git-lfs
13. Configures LaTeX environment (latexmkrc, Skim inverse search)
14. Bootstraps Neovim headless: plugins at their `nvim/lazy-lock.json` versions, then Treesitter parsers
15. Installs Python CLI tools (basedpyright, ruff) with `uv tool`

`./install.sh --update` skips steps 1-5. The script is idempotent: it's safe to
run multiple times, and a failed step prints `[warn]` rather than `[ok]`. The
repo can live anywhere (the script links from its own directory), but the hook
paths in `.claude/settings.json` assume `~/dotfiles`, so the script warns
elsewhere.

### Symlinks created

```
~/.gitconfig             -> ~/dotfiles/git/.gitconfig
~/.zshrc                 -> ~/dotfiles/zsh/.zshrc
~/.p10k.zsh              -> ~/dotfiles/zsh/.p10k.zsh
~/.tmux.conf             -> ~/dotfiles/tmux/.tmux.conf
~/.config/nvim           -> ~/dotfiles/nvim
~/.neomuttrc             -> ~/dotfiles/neomutt/.neomuttrc
~/.neomutt               -> ~/dotfiles/neomutt/.neomutt
~/.local/scripts/raycast -> ~/dotfiles/raycast
~/.claude/CLAUDE.md      -> ~/dotfiles/.claude/CLAUDE.md
~/.claude/RTK.md         -> ~/dotfiles/.claude/RTK.md
~/.claude/settings.json  -> ~/dotfiles/.claude/settings.json
~/.claude/skills         -> ~/dotfiles/.claude/skills
~/.claude/templates      -> ~/dotfiles/.claude/templates
~/.claude/rules          -> ~/dotfiles/.claude/rules
~/.claude/agents         -> ~/dotfiles/.claude/agents
~/.cursor/rules          -> ~/dotfiles/cursor/rules
~/.kilocode/rules        -> ~/dotfiles/kilocode/rules
~/.latexmkrc             -> ~/dotfiles/latex/.latexmkrc
```

`~/.latexmkrc` is linked only when MacTeX is installed.

## Tools

The annotated [`Brewfile`](Brewfile) is the catalogue: `brew bundle` installs
every uncommented entry, and commented entries are optional alternatives.

**Core tools:** `zsh`, `tmux`, `neovim`, `neomutt`, `git`, `git-lfs`, `gnupg`, `pinentry-mac`, `fzf`, `ripgrep`, `fd`, `bat`, `eza`, `zoxide`, `delta`, `atuin`, `direnv`, `lazygit`, `gh`, `jq`, `uv`, `just`, `shellcheck`, `mise`.

## LaTeX

MacTeX (via `brew install --cask mactex`) and Skim give the full TeX Live
toolchain with SyncTeX forward and inverse search; VimTeX and the `texlab` LSP
(installed by Mason) handle it in Neovim.

The `latex/.latexmkrc` provides optimized build configuration:
- Biber/BibTeX runs only when `.bib` files change
- Glossary compilation via `makeglossaries`
- Shell escape (for minted and TikZ externalization) is off; opt in per project with a `latexmkrc` beside the document
- Skim preview with SyncTeX auto-configured

Neovim has 59 LuaSnip snippets for LaTeX across TikZ, Beamer, and packages
(`nvim/snippets/tex/`).

## Post-install (manual steps)

1. **Secrets** -- edit `~/.zshrc.local` and fill in your API keys/tokens.
2. **GPG key** -- import your existing key (`gpg --import key.asc`) or generate a new one (`gpg --full-generate-key`). If the ID differs, set `[user] signingkey` in `~/.gitconfig.local` (included last by `git/.gitconfig`), not in the tracked file.
3. **Neomutt** -- copy the example account file and add credentials. See `neomutt/.neomutt/QUICKSTART.md`.
4. **iTerm2** -- set custom preferences folder to `~/dotfiles/iterm` in iTerm > Settings > General > Preferences.
5. **iTerm2 font** -- set font to `MesloLGS Nerd Font` in iTerm > Settings > Profiles > Text > Font.
6. **Raycast** -- add `~/.local/scripts/raycast` as a Script Command directory in Raycast preferences.
