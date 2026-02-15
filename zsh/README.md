# 🚀 ZSH Configuration - Nord Theme

Beautiful, powerful ZSH configuration with Nord theme, optimized for macOS, iTerm2, and modern development workflows.

![Nord Theme](https://www.nordtheme.com/assets/images/nord/repository-footer-separator.svg)

## ✨ Features

- 🎨 **Nord Theme** - Beautiful arctic-inspired colors
- ⚡ **Performance Optimized** - Lazy loading, async completions
- 🎯 **Developer Focused** - Git, Docker, K8s, Python, Go, Node.js
- 🎪 **Visual Enhancements** - ASCII art, system info, command timing
- 🔧 **100+ Aliases** - Productivity-boosting shortcuts
- 🧰 **Modern Tools** - FZF, Eza, Bat, Delta, Tmux integration
- 🎮 **Nvim Integration** - Fuzzy finding, session management

## 📦 What's Included

- `.zshrc` - Main ZSH configuration
- `.p10k.zsh` - Powerlevel10k prompt configuration
- `.tmux.conf` - Tmux configuration (Nord themed)
- `.zshrc.local.example` - Template for private/local settings

## 🎯 Prerequisites

### Required

```bash
# Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Powerlevel10k theme
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# ZSH plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Homebrew (macOS)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Recommended Tools

```bash
brew install \
  eza \           # Better ls
  bat \           # Better cat
  fzf \           # Fuzzy finder
  ripgrep \       # Better grep
  fd \            # Better find
  delta \         # Better git diff
  zoxide \        # Smarter cd
  fastfetch \     # System info
  tokei \         # Code statistics
  fx \            # JSON viewer
  glow \          # Markdown renderer
  tmux \          # Terminal multiplexer
  neovim          # Text editor

# Optional fun tools
brew install figlet lolcat cowsay fortune

# Fonts (for icons)
brew tap homebrew/cask-fonts
brew install --cask font-jetbrains-mono-nerd-font
```

## 🚀 Installation

### 1. Clone the repository

```bash
git clone https://github.com/YOUR_USERNAME/zshrc-config.git ~/dotfiles
```

### 2. Backup existing configs

```bash
mv ~/.zshrc ~/.zshrc.backup
mv ~/.p10k.zsh ~/.p10k.zsh.backup 2>/dev/null
mv ~/.tmux.conf ~/.tmux.conf.backup 2>/dev/null
```

### 3. Create symlinks

```bash
ln -s ~/dotfiles/.zshrc ~/.zshrc
ln -s ~/dotfiles/.p10k.zsh ~/.p10k.zsh
ln -s ~/dotfiles/.tmux.conf ~/.tmux.conf
```

### 4. Set up local config (for secrets)

```bash
cp ~/dotfiles/.zshrc.local.example ~/.zshrc.local
# Edit ~/.zshrc.local and add your API keys
```

### 5. Reload

```bash
source ~/.zshrc
```

## 🔐 Security

**IMPORTANT:** Never commit sensitive data!

- `.zshrc.local` is for private/sensitive environment variables
- This file is automatically sourced by `.zshrc` but NOT tracked in git
- Add your API keys, tokens, and secrets to `.zshrc.local`

Example `.zshrc.local`:
```bash
export SUPERMEMORY_CC_API_KEY="your-actual-key"
export GITHUB_TOKEN="your-token"
export OPENAI_API_KEY="your-key"
```

## 🎨 Theme Configuration

This config uses the Nord color scheme everywhere:

- ✅ ZSH syntax highlighting
- ✅ FZF (fuzzy finder)
- ✅ Bat (file preview)
- ✅ Git Delta (diffs)
- ✅ Tmux (status bar)
- ✅ Eza (file listing)

Pairs perfectly with:
- [Nord iTerm2](https://github.com/nordtheme/iterm2)
- [Nord Neovim](https://github.com/nordtheme/vim)

## 📚 Key Features

### Visual Enhancements

- **System info on startup** - Fastfetch shows system specs with ASCII art
- **Command execution time** - Shows duration for commands >1s
- **Directory info** - Auto-displays file/folder count and git branch when you cd
- **Background jobs indicator** - Visual alert for running background jobs
- **Project banners** - Create `.project-name` file for ASCII art banners
- **Git visualization** - Beautiful git trees and status displays

### 100+ Aliases

**Git:**
```bash
gs    # git status
ga    # git add .
gc    # git commit -m
gp    # git push
gl    # git pull
glog  # beautiful git log
gtree # git tree visualization
```

**Navigation:**
```bash
..    # cd ..
...   # cd ../..
ll    # eza -la with icons
lt    # tree view
```

**Tools:**
```bash
cat   # bat (with syntax highlighting)
find  # fd (faster find)
grep  # ripgrep (faster grep)
```

**Fun:**
```bash
weather         # Current weather
ascii "text"    # ASCII art generator
cowsay-random   # Random fortune
```

### Nvim Integration

- `v file.txt:42` - Open file at line 42
- `ve` - FZF file picker with preview
- `vrg "search"` - Ripgrep search → edit in nvim
- `vr` - Recent files picker
- `vs` / `vl` - Save/load nvim sessions
- `nvim-update` - Update all nvim plugins

### Tmux Integration

- `tn [name]` - Create tmux session with nvim
- `ta` - Attach to tmux with fzf picker
- Beautiful Nord-themed status bar
- Vim-style navigation

## 🎮 Customization

### Change Fastfetch Style

Edit `.zshrc` and change the config:
```bash
fastfetch --config examples/8.jsonc  # Try different numbers
```

### Enable Optional Features

Several features are commented out by default:

1. **Fortune on startup** - Uncomment around line 475
2. **K8s context indicator** - Uncomment around line 550
3. **Auto iTerm2 profile switching** - Uncomment around line 580

### Add Custom Aliases

Create `~/.zsh_aliases` and add your own:
```bash
alias myproject='cd ~/projects/myproject && nvim'
```

## 📖 Documentation

- [ZSH Guide](http://zsh.sourceforge.net/Guide/)
- [Oh My Zsh](https://ohmyz.sh/)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [Nord Theme](https://www.nordtheme.com/)

## 🤝 Contributing

Feel free to submit issues and enhancement requests!

## 📝 License

MIT License - Feel free to use and modify!

## 🙏 Credits

- [Nord Theme](https://www.nordtheme.com/)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [Oh My Zsh](https://ohmyz.sh/)
- All the amazing CLI tool developers

---

Made with ❄️ and ☕
