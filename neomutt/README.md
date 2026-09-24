# 📧 Neomutt Configuration - Catppuccin Mocha

Beautiful, powerful Neomutt configuration with the Catppuccin Mocha theme used across these dotfiles. A Gmail account with vim-like keybindings.

## ✨ Features

- 🎨 **Catppuccin Mocha** - Same palette as the terminal, tmux and editor
- ⌨️ **Vim Keybindings** - hjkl navigation, ZZ to quit, visual mode-inspired
- 🔐 **No secrets in the repo** - Gmail app password in the macOS Keychain
- 🗂️ **Sidebar** - Quick mailbox navigation
- 🧵 **Threading** - Conversation view with collapse/expand
- 📎 **HTML Email** - View HTML emails with fallback to plain text

## 📦 What's Included

- `.neomuttrc` - Main configuration file with keybindings and settings
- `catppuccin-mocha.neomuttrc` - Catppuccin Mocha color scheme
- `account.gmail.example` - Template for the Gmail account file
- Documentation files (QUICKSTART.md, VIM-GUIDE.md)

## 🚀 Installation

### 1. Install Neomutt

```bash
# macOS
brew install neomutt

# Linux (Debian/Ubuntu)
sudo apt install neomutt
```

### 2. Link the configuration

The dotfiles `install.sh` does this for you: it symlinks `~/.neomuttrc` and `~/.neomutt` to this directory and creates the cache directory, which lives outside the repo. By hand, from the dotfiles checkout:

```bash
ln -s "$PWD/neomutt/.neomuttrc" ~/.neomuttrc
ln -s "$PWD/neomutt/.neomutt" ~/.neomutt
mkdir -p ~/.cache/neomutt/{bodies,tmp}
chmod 700 ~/.cache/neomutt
touch ~/.neomutt/certificates
```

### 3. Set up Gmail

```bash
# Create account file from template
cp neomutt/account.gmail.example ~/.neomutt/account.gmail

# Edit with your details
nvim ~/.neomutt/account.gmail

# Store your Gmail app password (not your main password!) in the Keychain;
# security prompts for it, so it never lands in a file or your shell history
security add-generic-password -s neomutt-gmail -a your-email@gmail.com -w
```

**Note:** You need to create a Gmail App Password at: https://myaccount.google.com/apppasswords

## ⌨️ Key Bindings

### Vim-style Navigation

- `j/k` - Move down/up
- `gg` - Go to first message
- `G` - Go to last message
- `Ctrl-u/Ctrl-d` - Half page up/down
- `h/l` - Back/forward (pager)
- `/` - Search forward
- `?` - Search backward
- `n/N` - Next/previous search result

### Mailbox Management

Defined in `~/.neomutt/account.gmail`, next to the folder names they open:

- `gi` - Go to Inbox
- `gs` - Go to Sent
- `gd` - Go to Drafts
- `gt` - Go to Trash
- `ga` - Go to All Mail

### Message Actions

- `Enter` - Open message
- `dd` - Delete message
- `u` - Undelete message
- `r` - Reply
- `R` - Reply all
- `f` - Forward
- `c` - Compose new
- `A` - Archive
- `Ctrl-b` - Open a link from the message (urlscan)

### Vim-style Quit

- `q` - Quit
- `ZZ` - Save and quit
- `ZQ` - Quit without saving

### Sidebar

- `B` - Toggle sidebar
- `Ctrl-j` - Next mailbox
- `Ctrl-k` - Previous mailbox
- `Ctrl-o` - Open mailbox

## 🎨 Color Theme

Colors come from `catppuccin-mocha.neomuttrc` (the palette used by zsh, tmux and Neovim).

## 📚 Documentation

- `QUICKSTART.md` - Quick reference guide
- `VIM-GUIDE.md` - Complete vim keybindings reference

## 🔧 Customization

### Change Theme

Edit the colors in `~/.neomutt/catppuccin-mocha.neomuttrc`, or point the `source` line in `~/.neomuttrc` at another color file.

### Modify Keybindings

All keybindings are defined in `.neomuttrc` under the "Keybindings" section. Feel free to customize them to your preference.

## 🔗 Related Configurations

This configuration is part of the dotfiles repo, alongside the zsh, tmux, Neovim and iTerm2 configs.

## 📝 License

MIT License - Feel free to use and modify as you wish!

## 🙏 Credits

- [Neomutt](https://neomutt.org/) - Feature-rich email client
- [Catppuccin](https://catppuccin.com/) - Soothing pastel color palette
- Based on various neomutt configurations from the community

---

**Made by Alex Djalali**
