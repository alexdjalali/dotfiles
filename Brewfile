# =============================================================================
# Brewfile — Full development environment for macOS
# =============================================================================
# Run: brew bundle --file=~/dotfiles/Brewfile
# Uncommented items install automatically. Commented items are optional
# alternatives or personal-preference tools — uncomment as needed.

# Taps
tap "oven-sh/bun"

# =============================================================================
# Core CLI
# =============================================================================
brew "zsh"
brew "tmux"
brew "neovim"
brew "neomutt"
brew "git"
brew "git-lfs"
brew "gnupg"
brew "pinentry-mac"        # GUI pinentry for GPG signing
brew "mas"                 # Mac App Store CLI

# =============================================================================
# Modern CLI Replacements
# =============================================================================
brew "eza"                 # ls replacement (icons + git status)
brew "bat"                 # cat replacement (syntax highlighting)
brew "ripgrep"             # grep replacement (fast regex search)
brew "fd"                  # find replacement (fast file finder)
brew "sd"                  # sed replacement (intuitive find-and-replace)
brew "dust"                # du replacement (disk usage analyzer)
brew "procs"               # ps replacement (process viewer)
brew "btop"                # top replacement (system monitor)
brew "duf"                 # df replacement (disk free with graphs)
brew "delta"               # git diff pager (syntax highlighting)
brew "doggo"               # dig replacement (modern DNS client)
brew "xh"                  # curl replacement (friendly HTTP client)
brew "tlrc"                # man replacement (simplified man pages / tldr)
# brew "lsd"               # ls alternative (color + icons, if you prefer over eza)
# brew "bottom"            # top alternative (if you prefer over btop)
# brew "diff-so-fancy"     # diff alternative (if you prefer over delta)
# brew "difftastic"        # structural diff (AST-aware, complements delta)
# brew "httpie"            # curl alternative (if you prefer over xh)

# =============================================================================
# Shell Enhancements
# =============================================================================
brew "fzf"                 # Fuzzy finder (files, history, everything)
brew "zoxide"              # Smarter cd (frecency-based)
brew "direnv"              # Directory-specific environment variables
brew "atuin"               # Shell history with sync and search
brew "fastfetch"           # System info splash screen
brew "mise"                # Universal version manager (replaces nvm, rbenv, etc.)
brew "entr"                # File watcher (re-run commands on change)
# brew "navi"              # Interactive cheatsheet and snippet tool
# brew "watchexec"         # File watcher with glob patterns
# brew "mprocs"            # Run multiple processes in one terminal
# brew "zellij"            # Terminal multiplexer (tmux alternative)

# =============================================================================
# Languages & Package Managers
# =============================================================================
brew "go"
brew "python@3"
brew "uv"                  # Fast Python package manager
brew "pipx"                # Install Python CLI tools in isolation
brew "node"
brew "pnpm"                # Fast Node package manager
brew "oven-sh/bun/bun"     # Fast JS runtime + bundler
# brew "rustup"            # Rust toolchain installer
# brew "ruby"              # Ruby runtime
# brew "rbenv"             # Ruby version manager
# brew "julia"             # Julia runtime

# =============================================================================
# Git Tools
# =============================================================================
brew "lazygit"             # Terminal UI for git
brew "gh"                  # GitHub CLI
brew "gitleaks"            # Secret scanning for git repos
# brew "gitui"             # Alternative terminal UI for git
# brew "git-absorb"        # Auto-fixup commits into the right place
# brew "git-branchless"    # Stacking workflow for git
# brew "git-cliff"         # Changelog generator from commits

# =============================================================================
# Dev Tools
# =============================================================================
brew "jq"                  # JSON processor
brew "yq"                  # YAML processor
brew "fx"                  # Interactive JSON viewer
brew "glow"                # Terminal Markdown renderer
brew "tokei"               # Code statistics (lines, files, languages)
brew "shellcheck"          # Shell script linter
brew "pre-commit"          # Git hook framework
brew "just"                # Command runner (Makefile alternative)
brew "pandoc"              # Universal document converter
brew "hyperfine"           # CLI benchmarking tool
# brew "jless"             # Terminal JSON/YAML viewer
# brew "slides"            # Terminal-based presentations
# brew "scc"               # Fast code counter (tokei alternative)
# brew "yamlfmt"           # YAML formatter
# brew "openapi-generator" # Generate clients/servers from OpenAPI specs
# brew "semgrep"           # Static analysis (multi-language)

# =============================================================================
# Container & Kubernetes
# =============================================================================
brew "kubectl"             # Kubernetes CLI
brew "k9s"                 # Kubernetes TUI
brew "helm"                # Kubernetes package manager
brew "kind"                # Kubernetes in Docker (local clusters)
brew "kustomize"           # Kubernetes manifest customization
brew "kubectx"             # Fast context/namespace switching (includes kubens)
brew "stern"               # Multi-pod log tailing
brew "kubeconform"         # Kubernetes manifest validation
brew "lazydocker"          # Terminal UI for Docker
brew "hadolint"            # Dockerfile linter
brew "dive"                # Docker image layer explorer
brew "trivy"               # Container vulnerability scanner
# brew "krew"              # kubectl plugin manager
# brew "tilt"              # K8s dev workflow automation
# brew "kubescape"         # Kubernetes security scanning
# brew "conftest"          # OPA policy testing for configs
# brew "ctop"              # Container metrics viewer
# brew "cosign"            # Container image signing

# =============================================================================
# Infrastructure & Databases
# =============================================================================
brew "terraform"           # Infrastructure as code
brew "grpcurl"             # gRPC CLI client
brew "mongosh"             # MongoDB shell
brew "pgcli"               # PostgreSQL CLI with auto-complete
brew "redis"               # Redis CLI tools
# brew "lazysql"           # Terminal UI for SQL databases
# brew "lnav"              # Log file navigator
# brew "humanlog"          # Human-readable structured log output
# brew "mc"                # Midnight Commander (file manager)
# brew "bandwhich"         # Network utilization by process

# =============================================================================
# LaTeX & Academic Writing
# =============================================================================
# MacTeX provides: pdflatex, latexmk, bibtex, biber, TikZ, pgfplots, Beamer,
# and 4000+ packages (booktabs, siunitx, microtype, cleveref, minted, etc.)
cask "mactex"              # Full TeX Live distribution (~5GB)
cask "skim"                # PDF viewer with SyncTeX (forward/inverse search)

# =============================================================================
# Fonts
# =============================================================================
cask "font-meslo-lg-nerd-font"        # Primary terminal font (Powerlevel10k)
cask "font-jetbrains-mono-nerd-font"  # Alternative monospace font

# =============================================================================
# Fun
# =============================================================================
brew "figlet"              # ASCII art text banners
brew "lolcat"              # Rainbow terminal output
brew "fortune"             # Random quotes
brew "cowsay"              # ASCII cow with message

# =============================================================================
# Casks — Core
# =============================================================================
cask "docker"              # Container runtime
cask "iterm2"              # Feature-rich terminal
cask "raycast"             # Spotlight replacement
cask "rectangle"           # Window manager (keyboard-driven tiling)
cask "1password"           # Password manager

# =============================================================================
# Casks — macOS Optimization (uncomment as needed)
# =============================================================================
# cask "aldente"           # Battery charge limiter (cap at 80%)
# cask "monitorcontrol"    # Control external display brightness/volume via DDC
# cask "mac-mouse-fix"     # Customize mouse buttons, scroll, gestures
# cask "topnotch"          # Hides the MacBook notch with black menu bar
# cask "hidock"            # Different Dock layouts per display/workspace
# Amphetamine: Mac App Store only — install via: mas install 937984704

# =============================================================================
# Casks — Developer Applications (uncomment as needed)
# =============================================================================
# cask "cursor"            # AI-native code editor (VS Code fork)
# cask "datagrip"          # JetBrains database IDE
# cask "tableplus"         # Lightweight database GUI
# cask "insomnia"          # API client for REST and GraphQL
# cask "postman"           # API development and testing
# cask "github"            # GitHub Desktop (visual Git client)
# cask "gpg-suite-no-mail" # GPG Keychain for macOS
# cask "linear-linear"     # Project and issue tracking
# cask "chatgpt"           # OpenAI desktop app

# =============================================================================
# Casks — Terminals (uncomment as needed)
# =============================================================================
# cask "warp"              # AI-powered terminal with blocks
# cask "rio"               # GPU-accelerated terminal (Rust)
# cask "tabby"             # AI terminal with SSH and serial

# =============================================================================
# Casks — Browsers (uncomment as needed)
# =============================================================================
# cask "brave-browser"     # Privacy-focused Chromium browser
# cask "firefox"           # Mozilla browser
# cask "google-chrome"     # Google browser

# =============================================================================
# Casks — Screensavers (uncomment as needed)
# =============================================================================
# cask "aerial"            # Apple TV aerial screensavers
# cask "brooklyn"          # Apple-style animated screensavers
