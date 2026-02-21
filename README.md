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
14. Configures LaTeX environment (latexmkrc, Skim inverse search)
15. Bootstraps Neovim plugins and Treesitter parsers (headless)

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
~/.claude/CLAUDE.md        -> ~/dotfiles/.claude/CLAUDE.md
~/.claude/settings.json    -> ~/dotfiles/.claude/settings.json
~/.claude/commands         -> ~/dotfiles/.claude/commands
~/.cursor/rules            -> ~/dotfiles/cursor/rules
~/.cursor/skills-cursor    -> ~/dotfiles/cursor/skills-cursor
```

## Recommended Tools

Everything below is either installed via `brew bundle` (Brewfile), `brew install`, or as a macOS app. The Brewfile covers the core set; additional tools are installed separately as needed.

### Core CLI

| Tool | Description |
|------|-------------|
| `zsh` | Shell (Homebrew build, set as default) |
| `tmux` | Terminal multiplexer |
| `neovim` | Editor (AstroNvim-based config) |
| `neomutt` | Terminal email client |
| `git` + `git-lfs` | Version control |
| `gnupg` + `pinentry-mac` | GPG signing |

### Modern CLI Replacements

| Tool | Replaces | Description |
|------|----------|-------------|
| `eza` | `ls` | File listing with icons and git status |
| `lsd` | `ls` | Alternative ls with color and icons |
| `bat` | `cat` | Syntax-highlighted file viewer |
| `ripgrep` (`rg`) | `grep` | Fast regex search |
| `fd` | `find` | Fast file finder |
| `sd` | `sed` | Intuitive find-and-replace |
| `dust` | `du` | Disk usage analyzer |
| `procs` | `ps` | Process viewer |
| `btop` | `top`/`htop` | System monitor |
| `bottom` (`btm`) | `top` | Another system monitor |
| `duf` | `df` | Disk free with graphs |
| `delta` | `diff` | Git diff pager with syntax highlighting |
| `diff-so-fancy` | `diff` | Alternative diff prettifier |
| `difftastic` | `diff` | Structural diff (AST-aware) |
| `xh` | `curl` | Friendly HTTP client |
| `httpie` | `curl` | Another HTTP client with JSON support |
| `doggo` | `dig` | Modern DNS client |
| `tlrc` | `man` | Simplified man pages (tldr) |

### Shell Enhancements

| Tool | Description |
|------|-------------|
| `fzf` | Fuzzy finder (files, history, everything) |
| `zoxide` | Smarter `cd` (frecency-based) |
| `direnv` | Directory-specific environment variables |
| `atuin` | Shell history with sync and search |
| `fastfetch` | System info splash screen |
| `mise` | Universal version manager (replaces nvm, rbenv, etc.) |
| `navi` | Interactive cheatsheet and snippet tool |
| `entr` | File watcher (re-run commands on change) |
| `watchexec` | File watcher with glob patterns |
| `mprocs` | Run multiple processes in one terminal |
| `zellij` | Terminal multiplexer (tmux alternative) |

### Languages & Package Managers

| Tool | Description |
|------|-------------|
| `python@3.14` | Python runtime |
| `uv` | Fast Python package manager |
| `pipx` | Install Python CLI tools in isolation |
| `go` | Go runtime |
| `node` + `nvm` | Node.js runtime |
| `pnpm` | Fast Node package manager |
| `bun` | Fast JS runtime + bundler (via `oven-sh/bun` tap) |
| `rust` | Rust toolchain |
| `ruby` + `rbenv` | Ruby runtime + version manager |
| `julia` | Julia runtime |

### Git Tools

| Tool | Description |
|------|-------------|
| `lazygit` | Terminal UI for git |
| `gitui` | Alternative terminal UI for git |
| `gh` | GitHub CLI |
| `git-absorb` | Auto-fixup commits into the right place |
| `git-branchless` | Stacking workflow for git |
| `git-cliff` | Changelog generator from commits |
| `gitleaks` | Secret scanning for git repos |

### Dev Tools

| Tool | Description |
|------|-------------|
| `jq` | JSON processor |
| `yq` | YAML processor |
| `fx` | Interactive JSON viewer |
| `jless` | Terminal JSON/YAML viewer |
| `glow` | Terminal Markdown renderer |
| `slides` | Terminal-based presentations |
| `tokei` | Code statistics (lines, files, languages) |
| `scc` | Fast code counter (tokei alternative) |
| `shellcheck` | Shell script linter |
| `pre-commit` | Git hook framework |
| `just` | Command runner (Makefile alternative) |
| `pandoc` | Universal document converter |
| `hyperfine` | CLI benchmarking tool |
| `yamlfmt` | YAML formatter |
| `openapi-generator` | Generate clients/servers from OpenAPI specs |
| `semgrep` | Static analysis (multi-language) |

### Container & Kubernetes

| Tool | Description |
|------|-------------|
| `docker` | Container runtime (formula + cask) |
| `kubectl` | Kubernetes CLI |
| `k9s` | Kubernetes TUI |
| `helm` | Kubernetes package manager |
| `kind` | Kubernetes in Docker (local clusters) |
| `kustomize` | Kubernetes manifest customization |
| `kubectx` + `kubens` | Fast context/namespace switching |
| `krew` | kubectl plugin manager |
| `stern` | Multi-pod log tailing |
| `tilt` | K8s dev workflow automation |
| `kubeconform` | Kubernetes manifest validation |
| `kubescape` | Kubernetes security scanning |
| `conftest` | OPA policy testing for configs |
| `dive` | Docker image layer explorer |
| `ctop` | Container metrics viewer |
| `lazydocker` | Terminal UI for Docker |
| `hadolint` | Dockerfile linter |
| `cosign` | Container image signing |
| `trivy` | Container vulnerability scanner |

### Infrastructure

| Tool | Description |
|------|-------------|
| `terraform` | Infrastructure as code |
| `grpcurl` | gRPC curl (CLI for gRPC services) |
| `mongosh` | MongoDB shell |
| `pgcli` | PostgreSQL CLI with auto-complete |
| `lazysql` | Terminal UI for SQL databases |
| `redis` | Redis CLI tools |
| `lnav` | Log file navigator |
| `humanlog` | Human-readable structured log output |
| `mc` | Midnight Commander (file manager) |
| `bandwhich` | Network utilization by process |

### LaTeX & Academic Writing

| Tool | Description |
|------|-------------|
| MacTeX | Full TeX Live distribution (pdflatex, latexmk, bibtex, biber) |
| **Skim** | PDF viewer with SyncTeX forward/inverse search |
| `texlab` | LaTeX LSP (installed via Mason in Neovim) |
| VimTeX | Neovim plugin: compilation, PDF sync, text objects |

Includes 4000+ packages out of the box: TikZ, pgfplots, Beamer, booktabs, siunitx, microtype, cleveref, glossaries-extra, minted, algorithm2e, adjustbox, hyperref, and more.

The `latex/.latexmkrc` provides optimized build configuration:
- Biber/BibTeX runs only when `.bib` files change
- Glossary compilation via `makeglossaries`
- Shell-escape enabled for minted and TikZ externalization
- Skim preview with SyncTeX auto-configured

Neovim has 59 custom LuaSnip snippets for LaTeX:
- 20 TikZ/pgfplots snippets (nodes, flowcharts, commutative diagrams, plots)
- 17 Beamer snippets (frames, columns, blocks, overlays, incremental reveal)
- 22 package snippets (article template, booktabs tables, siunitx, equations)

### macOS Optimization (Casks)

| App | Description |
|-----|-------------|
| **AlDente** | Battery charge limiter (cap at 80% for longevity) |
| **MonitorControl** | Control external display brightness/volume via DDC |
| **Mac Mouse Fix** | Customize mouse buttons, scroll, and gestures |
| **TopNotch** | Hides the MacBook notch with a black menu bar |
| **HiDock** | Different Dock layouts per display/workspace |
| **Rectangle** | Window manager (keyboard-driven tiling) |
| **Amphetamine** | Keep-awake utility (Mac App Store only: `mas install 937984704`) |
| **Raycast** | Spotlight replacement with extensions and scripts |

### Terminals

| App | Description |
|-----|-------------|
| **iTerm2** | Feature-rich terminal (primary) |
| **Warp** | AI-powered terminal with blocks |
| **Rio** | GPU-accelerated terminal (Rust) |
| **Tabby** | AI terminal with SSH and serial |

### Developer Applications

| App | Description |
|-----|-------------|
| **Cursor** | AI-native code editor (VS Code fork) |
| **DataGrip** | JetBrains database IDE |
| **TablePlus** | Lightweight database GUI |
| **Insomnia** | API client for REST and GraphQL |
| **Postman** | API development and testing |
| **GitHub Desktop** | Visual Git client |
| **GPG Keychain** | macOS GPG key management |
| **Linear** | Project and issue tracking |
| **ChatGPT** | OpenAI desktop app |

### Browsers

| App | Description |
|-----|-------------|
| **Brave Browser** | Privacy-focused Chromium browser |
| **Firefox** | Mozilla browser |
| **Google Chrome** | Google browser |

### Screensavers

| Cask | Description |
|------|-------------|
| **Aerial** | Apple TV aerial screensavers |
| **Brooklyn** | Apple-style animated screensavers |

### Fonts

| Font | Description |
|------|-------------|
| MesloLGS Nerd Font | Primary terminal font (Powerlevel10k) |
| JetBrains Mono Nerd Font | Alternative monospace font |

### Fun

| Tool | Description |
|------|-------------|
| `figlet` | ASCII art text banners |
| `lolcat` | Rainbow terminal output |
| `fortune` | Random quotes |
| `cowsay` | ASCII cow with message |

## Post-install (manual steps)

1. **Secrets** -- edit `~/.zshrc.local` and fill in your API keys/tokens.
2. **GPG key** -- import your existing key (`gpg --import key.asc`) or generate a new one (`gpg --full-generate-key`), then update `git/.gitconfig` signingkey if the ID changed.
3. **Neomutt** -- copy example account files and add credentials. See `neomutt/.neomutt/QUICKSTART.md`.
4. **iTerm2** -- set custom preferences folder to `~/dotfiles/iterm` in iTerm > Settings > General > Preferences.
5. **iTerm2 font** -- set font to `MesloLGS Nerd Font` in iTerm > Settings > Profiles > Text > Font.
6. **Raycast** -- add `~/.local/scripts/raycast` as a Script Command directory in Raycast preferences.
