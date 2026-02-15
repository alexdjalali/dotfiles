# 📧 Neomutt Configuration - Nord Theme

Beautiful, powerful Neomutt configuration with Nord theme matching zshrc and nvim. Multi-account setup for Gmail and Office 365 with vim-like keybindings.

![Nord Theme](https://www.nordtheme.com/assets/images/nord/repository-footer-separator.svg)

## ✨ Features

- 🎨 **Nord Theme** - Arctic-inspired colors matching your terminal and editor
- 📬 **Multi-Account** - Easy switching between Gmail and Office 365
- ⌨️ **Vim Keybindings** - hjkl navigation, ZZ to quit, visual mode-inspired
- 🔐 **OAuth2 Support** - Secure authentication for Office 365
- 🗂️ **Sidebar** - Quick mailbox navigation
- 🧵 **Threading** - Conversation view with collapse/expand
- 📎 **HTML Email** - View HTML emails with fallback to plain text

## 📦 What's Included

- `.neomuttrc` - Main configuration file with keybindings and settings
- `nord.neomuttrc` - Nord color scheme (matches zshrc and nvim)
- `solarized-dark-256.neomuttrc` - Alternative Solarized Dark theme
- `account.*.example` - Template files for account configuration
- `mutt_oauth2.py` - OAuth2 authentication script for Office 365
- Documentation files (QUICKSTART.md, MULTI-ACCOUNT.md, VIM-GUIDE.md)

## 🚀 Installation

### 1. Install Neomutt

```bash
# macOS
brew install neomutt

# Linux (Debian/Ubuntu)
sudo apt install neomutt
```

### 2. Clone this repository

```bash
git clone https://github.com/alexdjalali/neomutt-config.git
cd neomutt-config
```

### 3. Copy configuration files

```bash
# Create neomutt directory
mkdir -p ~/.neomutt

# Copy main config
cp .neomuttrc ~/

# Copy theme files
cp nord.neomuttrc ~/.neomutt/
cp solarized-dark-256.neomuttrc ~/.neomutt/

# Copy OAuth2 script
cp mutt_oauth2.py ~/.neomutt/
chmod +x ~/.neomutt/mutt_oauth2.py

# Copy documentation
cp *.md ~/.neomutt/
```

### 4. Set up accounts

#### Gmail

```bash
# Create account file from template
cp account.gmail.example ~/.neomutt/account.gmail

# Edit with your details
nvim ~/.neomutt/account.gmail

# Store your Gmail app password (not your main password!)
echo "your-app-password" > ~/.neomutt/gmail.pass
chmod 600 ~/.neomutt/gmail.pass
```

**Note:** You need to create a Gmail App Password at: https://myaccount.google.com/apppasswords

#### Office 365 (Optional)

See `MULTI-ACCOUNT.md` for detailed Office 365 OAuth2 setup instructions.

### 5. Create empty files for cache

```bash
mkdir -p ~/.neomutt/cache/{headers,bodies}
mkdir -p ~/.neomutt/tmp
touch ~/.neomutt/aliases
touch ~/.neomutt/certificates
```

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
- `A` - Archive (Gmail)

### Vim-style Quit

- `q` - Quit
- `ZZ` - Save and quit
- `ZQ` - Quit without saving

### Sidebar

- `B` - Toggle sidebar
- `Ctrl-j` - Next mailbox
- `Ctrl-k` - Previous mailbox
- `Ctrl-o` - Open mailbox

### Account Switching

- `F2` or `,g` - Switch to Gmail
- `F3` or `,t` - Switch to GT/Office 365

## 🎨 Color Theme

The Nord theme provides beautiful, consistent colors:

- **Background:** Polar Night (#2E3440, #3B4252)
- **Foreground:** Snow Storm (#D8DEE9, #E5E9F0)
- **Accents:** Frost colors (blues/cyans) and Aurora colors (green, yellow, red, purple)
- **New/Unread:** Frost Cyan (#88C0D0)
- **Flagged:** Aurora Yellow (#EBCB8B)
- **Deleted:** Aurora Red (#BF616A)

## 📚 Documentation

- `QUICKSTART.md` - Quick reference guide
- `MULTI-ACCOUNT.md` - Multi-account setup guide
- `VIM-GUIDE.md` - Complete vim keybindings reference

## 🔧 Customization

### Change Theme

Edit `~/.neomuttrc` and change the source line:

```bash
# Use Nord theme (default)
source ~/.neomutt/nord.neomuttrc

# Or use Solarized Dark
source ~/.neomutt/solarized-dark-256.neomuttrc
```

### Modify Keybindings

All keybindings are defined in `.neomuttrc` under the "Keybindings" section. Feel free to customize them to your preference.

### Add More Accounts

Copy the account template and modify the `.neomuttrc` to add more F-key shortcuts for switching accounts.

## 🔗 Related Configurations

This configuration is part of a Nord-themed development environment:

- [nvim-config](https://github.com/alexdjalali/nvim-config) - Neovim with Nord theme
- [zshrc-config](https://github.com/alexdjalali/zshrc-config) - ZSH with Nord theme
- [iterm-config](https://github.com/alexdjalali/iterm-config) - iTerm2 with Nord theme

## 📝 License

MIT License - Feel free to use and modify as you wish!

## 🙏 Credits

- [Neomutt](https://neomutt.org/) - Feature-rich email client
- [Nord Theme](https://www.nordtheme.com/) - Beautiful arctic color palette
- Based on various neomutt configurations from the community

---

**Made with ❄️ by Alex Djalali**
