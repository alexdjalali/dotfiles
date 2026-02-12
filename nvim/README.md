# 🚀 Neovim Configuration - Nord Theme

> A powerful, beautiful Neovim setup powered by AstroNvim with Nord theme and extensive plugin ecosystem

![Neovim](https://img.shields.io/badge/NeoVim-%2357A143.svg?&style=for-the-badge&logo=neovim&logoColor=white)
![Lua](https://img.shields.io/badge/lua-%232C2D72.svg?style=for-the-badge&logo=lua&logoColor=white)
![Nord](https://img.shields.io/badge/Nord-Theme-88C0D0?style=for-the-badge)

## ✨ Features

- 🎨 **Nord Theme** - Beautiful arctic-inspired colors across all UI elements
- ⚡ **Lightning Fast** - Lazy loading, optimized performance
- 🧰 **LSP Powered** - Full IDE features with Mason-managed language servers
- 🔍 **Telescope** - Fuzzy finding for files, text, and more
- 🌳 **Treesitter** - Advanced syntax highlighting and code understanding
- 🧪 **Testing** - Neotest integration for Python, Go, JS/TS
- 🐛 **Debugging** - DAP integration for multiple languages
- 🎯 **Git Integration** - Diffview, signs, and more
- 🎨 **UI Enhancements** - Rainbow brackets, scrollbar, breadcrumbs, and more
- 🤖 **AI Assistance** - Multiple AI tools integrated

## 📦 What's Included

### Core Framework
- **AstroNvim v5** - Modern Neovim distribution
- **Lazy.nvim** - Plugin manager
- **Nord Theme** - Consistent color scheme

### Language Support (via AstroCommunity)
- 🐍 Python (Ruff LSP)
- 🐹 Go
- 📘 TypeScript/JavaScript
- 🐳 Docker
- ☁️ Terraform
- 📦 YAML/JSON
- 🎨 Tailwind CSS
- ⎈ Helm
- 🐚 Bash

### Testing & Debugging
- **Neotest** - Universal test runner
  - Python (pytest)
  - Go
  - Jest
  - Vitest
- **nvim-dap** - Debug Adapter Protocol
- **nvim-coverage** - Test coverage visualization

### Git Integration
- **Diffview** - Beautiful diff viewing
- **Gitsigns** - Git decorations
- **Git conflict** - Conflict resolution tools

### UI Enhancements
- **Rainbow delimiters** - Colorful bracket pairs
- **Indent blankline** - Visual indent guides
- **Mini.indentscope** - Current scope highlighting
- **Scrollbar** - Visual scrollbar with diagnostics
- **Todo comments** - Highlight TODO, FIXME, etc.
- **Trouble** - Better diagnostics UI
- **Noice** - Enhanced UI for messages and cmdline
- **Barbecue** - VS Code-like breadcrumbs
- **Incline** - Floating filenames

### Productivity
- **Telescope** - Fuzzy finder for everything
- **Flash** - Quick navigation
- **Neo-tree** - File explorer
- **Which-key** - Keybinding hints
- **Twilight** - Dim inactive code
- **Nvim-UFO** - Better folding

### AI & Code Assistance
- **Copilot** - GitHub Copilot integration
- **CopilotChat** - Chat with Copilot
- **Avante** - AI-powered code assistant
- **CodeCompanion** - Additional AI features

### HTTP & API Testing
- **Kulala** - HTTP client for .http files
- **Rest.nvim** - Alternative REST client

### Editing Enhancements
- **Mini.surround** - Surround text objects
- **Vim-visual-multi** - Multiple cursors
- **Treesitter-context** - Sticky function headers
- **Illuminate** - Highlight word under cursor

### Documentation & Notes
- **Markdown preview** - Live markdown rendering
- **Render-markdown** - Beautiful markdown in buffer
- **Obsidian** - Note-taking integration

## 🚀 Installation

### Prerequisites

```bash
# Neovim 0.10.0+
brew install neovim

# Ripgrep (for Telescope)
brew install ripgrep

# fd (for file finding)
brew install fd

# Node.js (for LSP servers)
brew install node

# Python (for Python support)
brew install python

# Optional: Nerd Font
brew tap homebrew/cask-fonts
brew install --cask font-jetbrains-mono-nerd-font
```

### Install This Configuration

#### 1. Backup existing config

```bash
mv ~/.config/nvim ~/.config/nvim.backup
mv ~/.local/share/nvim ~/.local/share/nvim.backup
mv ~/.local/state/nvim ~/.local/state/nvim.backup
mv ~/.cache/nvim ~/.cache/nvim.backup
```

#### 2. Clone this repository

```bash
git clone https://github.com/alexdjalali/nvim-config.git ~/.config/nvim
```

#### 3. Start Neovim

```bash
nvim
```

Plugins will install automatically on first launch.

#### 4. Install Language Servers

```vim
:Mason
```

Install the servers you need:
- `pyright` or `ruff` (Python)
- `gopls` (Go)
- `ts_ls` (TypeScript)
- `lua_ls` (Lua)
- `bashls` (Bash)
- And more...

## ⌨️ Key Mappings

### General
| Key | Description |
|-----|-------------|
| `<leader>` | Space |
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Find buffers |
| `<leader>fh` | Find help |
| `<leader>e` | Toggle Neo-tree |

### LSP
| Key | Description |
|-----|-------------|
| `gd` | Go to definition |
| `gr` | Find references |
| `K` | Hover documentation |
| `<leader>ca` | Code actions |
| `<leader>cr` | Rename symbol |
| `<leader>cf` | Format code |

### Testing (Neotest)
| Key | Description |
|-----|-------------|
| `<leader>tr` | Run nearest test |
| `<leader>tf` | Run test file |
| `<leader>td` | Debug test |
| `<leader>ts` | Toggle test summary |
| `<leader>to` | Show test output |

### Debugging (DAP)
| Key | Description |
|-----|-------------|
| `<leader>db` | Toggle breakpoint |
| `<leader>dc` | Continue |
| `<leader>di` | Step into |
| `<leader>do` | Step over |
| `<leader>dO` | Step out |
| `<leader>dr` | Open REPL |

### Git
| Key | Description |
|-----|-------------|
| `<leader>gd` | Git diff view |
| `<leader>gc` | Git commits |
| `<leader>gs` | Git status |
| `]h` | Next hunk |
| `[h` | Previous hunk |

### AI (Copilot)
| Key | Description |
|-----|-------------|
| `<leader>aa` | Toggle Copilot |
| `<leader>ac` | Copilot chat |
| `<leader>ae` | Copilot explain |
| `<leader>af` | Copilot fix |

### HTTP Testing (Kulala)
| Key | Description |
|-----|-------------|
| `<leader>rr` | Run HTTP request |
| `<leader>ra` | Run all requests |
| `<leader>ri` | Inspect request |

## 🎨 Customization

### Change Colorscheme

Edit `lua/plugins/astroui.lua`:

```lua
return {
  "AstroNvim/astroui",
  opts = {
    colorscheme = "nord",  -- Change to your preferred theme
  },
}
```

### Add Custom Plugins

Create a new file in `lua/plugins/`:

```lua
-- lua/plugins/myplugin.lua
return {
  "author/plugin-name",
  opts = {
    -- plugin options
  },
}
```

### Modify Keymaps

Edit `lua/plugins/astrocore.lua` or create custom mappings:

```lua
opts = {
  mappings = {
    n = {
      ["<leader>xx"] = { "<cmd>YourCommand<cr>", desc = "Description" },
    },
  },
}
```

## 📁 Structure

```
~/.config/nvim/
├── init.lua                    # Entry point
├── lua/
│   ├── lazy_setup.lua          # Lazy.nvim configuration
│   ├── polish.lua              # Final polish/customizations
│   ├── community.lua           # AstroCommunity imports
│   └── plugins/
│       ├── astrocore.lua       # Core AstroNvim settings
│       ├── astrolsp.lua        # LSP configuration
│       ├── astroui.lua         # UI & colorscheme
│       ├── testing.lua         # Neotest & coverage
│       ├── debugging.lua       # DAP configuration
│       ├── python.lua          # Python-specific
│       ├── visual.lua          # Visual enhancements
│       ├── ui.lua              # UI plugins
│       ├── git.lua             # Git integration
│       ├── ai.lua              # AI assistants
│       ├── http.lua            # HTTP clients
│       ├── markdown.lua        # Markdown tools
│       ├── editing.lua         # Editing enhancements
│       ├── navigation.lua      # Navigation tools
│       ├── productivity.lua    # Productivity plugins
│       ├── file-management.lua # File operations
│       ├── code-info.lua       # Code understanding
│       ├── cheatsheet.lua      # Cheatsheets
│       ├── devops-lsp.lua      # DevOps LSPs
│       ├── fun.lua             # Fun plugins
│       └── user.lua            # User customizations
└── README.md                   # This file
```

## 🔧 Maintenance

### Update Plugins

```vim
:Lazy sync
```

### Update Language Servers

```vim
:Mason
```

Then press `U` to update all.

### Health Check

```vim
:checkhealth
```

### Clean Unused Plugins

```vim
:Lazy clean
```

## 🎯 Language-Specific Setup

### Python

The config automatically detects virtual environments:

```bash
# Create venv
python3 -m venv .venv

# Activate
source .venv/bin/activate

# Install in venv
pip install ruff pytest
```

Neovim will automatically use the venv's Python!

### Go

Install Go tools:

```bash
go install golang.org/x/tools/gopls@latest
go install github.com/go-delve/delve/cmd/dlv@latest
```

### TypeScript/JavaScript

Install globally or in project:

```bash
npm install -g typescript typescript-language-server
```

## 🐛 Debugging Setup

### Python

The config includes DAP for Python:

```bash
# Install debugpy
pip install debugpy
```

### Go

```bash
# Install delve
go install github.com/go-delve/delve/cmd/dlv@latest
```

### JavaScript/TypeScript

```bash
# Install node debug
npm install -g vscode-js-debug
```

## 📚 Learning Resources

### Neovim
- [Neovim Documentation](https://neovim.io/doc/)
- [AstroNvim Documentation](https://docs.astronvim.com/)
- [Lazy.nvim](https://github.com/folke/lazy.nvim)

### Plugins
- [Telescope](https://github.com/nvim-telescope/telescope.nvim)
- [Treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
- [LSP](https://github.com/neovim/nvim-lspconfig)
- [Neotest](https://github.com/nvim-neotest/neotest)

## 🤝 Contributing

Feel free to submit issues and pull requests!

## 📝 License

MIT License

## 🙏 Credits

- [AstroNvim](https://github.com/AstroNvim/AstroNvim) - Amazing Neovim distribution
- [Nord Theme](https://www.nordtheme.com/) - Beautiful color scheme
- All the plugin authors whose work makes this possible

## 💡 Tips & Tricks

### Quick Commands

```vim
" Update everything
:Lazy sync | :Mason update

" Profile startup time
nvim --startuptime startup.log

" Edit config
:e ~/.config/nvim/lua/plugins/

" Reload config (some changes)
:source %
```

### ZSH Integration

If you're using my [ZSH config](https://github.com/alexdjalali/zshrc-config):

```bash
# Open file at specific line
v file.txt:42

# FZF file picker
ve

# Search and edit
vrg "search term"

# Recent files
vr

# Update plugins
nvim-update
```

### Recommended Workflow

1. **File Navigation:** Use `<leader>ff` (Telescope) or `<leader>e` (Neo-tree)
2. **Code Search:** Use `<leader>fg` (live grep)
3. **Git Changes:** Use `<leader>gd` (diffview)
4. **Testing:** Use `<leader>tr` (run nearest test)
5. **Debugging:** Set breakpoints with `<leader>db`, then `<leader>dc` to start

### Performance Tips

- Use `:Lazy profile` to see plugin load times
- Disable unused language servers in Mason
- Use treesitter for syntax highlighting (not regex)
- Keep scrollback reasonable in terminal buffers

## 🎨 Screenshots

_Add your screenshots here!_

```bash
# Take a screenshot showing:
# 1. Nord theme
# 2. File tree
# 3. Code with LSP
# 4. Telescope
# 5. Test results
```

---

**Nord-themed • LSP-powered • Test-integrated**

Made with ❄️ and ☕
