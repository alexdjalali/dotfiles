# Raycast Script Commands

Custom Raycast scripts for a unified developer workflow.

## Installation

1. Open Raycast (`⌘ + Space`)
2. Type `Extensions` → select "Extensions"
3. Click `+` → "Add Script Directory"
4. Select this directory (or symlink `~/.local/scripts/raycast` to it)

## Scripts

| Script | Description | Icon |
|--------|-------------|------|
| `open-in-nvim.sh` | Open file/directory in Neovim (iTerm) | 📝 |
| `open-project.sh` | Open project in iTerm + Neovim | 📁 |
| `tableplus-connect.sh` | Open TablePlus database client | 🗄️ |
| `insomnia-open.sh` | Open Insomnia API client | 🌙 |
| `dev-stack.sh` | Start full dev environment | 🚀 |
| `docker-status.sh` | Show running Docker containers (inline) | 🐳 |
| `k8s-context.sh` | Show current Kubernetes context (inline) | ☸️ |
| `git-status-all.sh` | Check all projects for uncommitted changes | 📊 |
| `lazygit-here.sh` | Open LazyGit in iTerm | 🌿 |
| `quick-note.sh` | Add timestamped note to daily file | 📝 |
| `claude-code.sh` | Open Claude Code CLI in iTerm | 🤖 |
| `search-github.sh` | Search GitHub repositories | 🐙 |
| `search-stackoverflow.sh` | Search Stack Overflow | 📚 |
| `go-docs.sh` | Open Go package documentation | 🐹 |
| `python-docs.sh` | Open Python package on PyPI | 🐍 |
| `linear-open.sh` | Open Linear project management | 📋 |

## Usage

After installation, press `⌘ + Space` and type any command name.

### Inline Scripts

`docker-status.sh` and `k8s-context.sh` run in inline mode, showing live status in the Raycast bar.

### Arguments

Some scripts accept arguments:

```
Open in Neovim → ~/projects/myfile.py
Open Project → my-project-name
TablePlus Connect → connection-name
```

## Symlink Setup

To keep scripts in sync:

```bash
# Remove existing and symlink
rm -rf ~/.local/scripts/raycast
ln -s ~/projects/raycast-scripts ~/.local/scripts/raycast
```

## License

MIT
