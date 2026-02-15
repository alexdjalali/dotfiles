# 🖥️ iTerm2 Configuration - Nord Theme

Beautiful iTerm2 setup with Nord color scheme and optimized visual settings.

![Nord Theme](https://www.nordtheme.com/assets/images/nord/repository-footer-separator.svg)

## ✨ Features

- 🎨 **Nord Color Scheme** - Arctic-inspired, easy on the eyes
- 💎 **Glass Effect** - Beautiful transparency with blur
- 📊 **Status Bar** - Shows git branch, CPU, memory, and more
- 🎯 **Optimized Settings** - Smooth performance, great fonts
- 🔔 **Smart Triggers** - Auto-highlight ERROR, WARNING, SUCCESS
- 🏷️ **Enhanced Badges** - Shows current context and versions

## 📦 What's Included

- `Nord.itermcolors` - Nord color scheme for iTerm2
- `com.googlecode.iterm2.plist` - Full iTerm2 preferences export
- Configuration guide and best practices

## 🚀 Installation

### Option 1: Import Full Preferences (Recommended)

**⚠️ WARNING:** This will overwrite ALL your iTerm2 settings!

1. **Backup current settings first:**
   ```bash
   cp ~/Library/Preferences/com.googlecode.iterm2.plist ~/iterm2-backup.plist
   ```

2. **Close iTerm2 completely** (⌘Q)

3. **Import preferences:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/iterm-config.git ~/dotfiles-iterm
   cp ~/dotfiles-iterm/com.googlecode.iterm2.plist ~/Library/Preferences/
   ```

4. **Restart iTerm2**

### Option 2: Import Only Color Scheme (Safer)

1. **Clone repository:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/iterm-config.git ~/dotfiles-iterm
   ```

2. **Import color scheme:**
   ```bash
   open ~/dotfiles-iterm/Nord.itermcolors
   ```

3. **Apply in iTerm2:**
   - Open iTerm2 → Preferences (⌘,)
   - Go to **Profiles** → **Colors**
   - Click **Color Presets** (bottom right)
   - Select **Nord**

### Option 3: Manual Configuration (Most Control)

Follow the manual setup guide below to configure each setting individually.

## 🎨 Manual Setup Guide

### 1. Install Nord Color Scheme

```bash
# Import Nord colors
open Nord.itermcolors
```

Then:
- iTerm2 → Preferences → Profiles → Colors
- Color Presets → Nord

### 2. Install Nerd Font

```bash
brew tap homebrew/cask-fonts
brew install --cask font-jetbrains-mono-nerd-font
```

Apply font:
- Preferences → Profiles → Text
- Font: **JetBrainsMono Nerd Font, 13pt**
- ✅ Use ligatures

### 3. Enable Glass Effect

- Preferences → Profiles → Window
- **Transparency:** 12-15%
- **Blur:** 15-20
- ✅ **Keep background colors opaque**

### 4. Configure Status Bar

- Preferences → Profiles → Session
- ✅ **Status bar enabled**
- Click **Configure Status Bar**

**Add these components** (left to right):
1. Current Directory
2. Git Branch
3. CPU Utilization
4. Memory Utilization
5. Network Throughput (optional)

**Status bar settings:**
- Position: Bottom
- Theme: Dark
- Auto-rainbow: ✅ (optional)

### 5. Set Minimal Theme

- Preferences → Appearance → General
- **Theme:** Minimal
- ✅ **Hide scrollbars**
- **Tab bar location:** Top
- ✅ **Show tab bar even when there is only one tab**
- **Tab outline:** 1pt

### 6. Configure Badges (Optional)

- Preferences → Profiles → General → Badge
- Add badge text:
  ```
  \(user.gitBranch)
  \(user.currentDir)
  ```

**Note:** Requires [ZSH configuration](https://github.com/YOUR_USERNAME/zshrc-config) for dynamic badge values.

### 7. Add Custom Triggers

- Preferences → Profiles → Advanced → Triggers
- Click **Edit**, then **+** to add:

| Regular Expression | Action | Parameters |
|-------------------|--------|------------|
| `ERROR\|error` | Highlight Text | Red background |
| `WARNING\|warning\|WARN` | Highlight Text | Yellow background |
| `SUCCESS\|success` | Highlight Text | Green background |
| `FAIL\|failed` | Highlight Text | Red background |
| `\[DONE\]` | Show Alert | "Task Complete!" |

### 8. Additional Recommended Settings

**General:**
- Preferences → General
- ✅ **Native full screen windows**
- ✅ **Separate window title per tab**

**Terminal:**
- Preferences → Profiles → Terminal
- **Scrollback lines:** 10000
- ✅ **Unlimited scrollback**
- ✅ **Save lines to scrollback when an app status bar is present**

**Keys:**
- Preferences → Keys → Key Bindings
- Add useful shortcuts:
  - ⌘T: New Tab
  - ⌘W: Close Tab
  - ⌘D: Split Vertically
  - ⌘⇧D: Split Horizontally

## 🎨 Nord Color Palette

The Nord theme uses these beautiful arctic colors:

### Polar Night (Darks)
- `#2E3440` - Background
- `#3B4252` - Selection
- `#434C5E` - Comments
- `#4C566A` - Borders

### Snow Storm (Lights)
- `#D8DEE9` - Foreground
- `#E5E9F0` - Bright
- `#ECEFF4` - Brightest

### Frost (Blues/Cyans)
- `#8FBCBB` - Cyan
- `#88C0D0` - Bright Cyan
- `#81A1C1` - Blue
- `#5E81AC` - Dark Blue

### Aurora (Accents)
- `#BF616A` - Red
- `#D08770` - Orange
- `#EBCB8B` - Yellow
- `#A3BE8C` - Green
- `#B48EAD` - Purple

## 🎯 Recommended Profile Settings

### Window Settings
```
Transparency: 12-15%
Blur: 15-20
Columns: 120
Rows: 30
Style: Normal
Screen: Main Screen
Space: Current Space
```

### Text Settings
```
Font: JetBrainsMono Nerd Font
Size: 13pt
Spacing: 100% horizontal, 100% vertical
Anti-aliased: ✅
Use ligatures: ✅
```

### Terminal Settings
```
Report terminal type: xterm-256color
Scrollback lines: Unlimited
Character encoding: Unicode (UTF-8)
```

## 🎨 Creating Custom Profiles

You can create specialized profiles for different contexts:

### Production Profile (Red)
- Clone default profile
- Name: "Production"
- Colors: Use warmer reds for background
- Badge: "🔴 PROD"

### Staging Profile (Orange)
- Clone default profile
- Name: "Staging"
- Colors: Orange tint
- Badge: "🟠 STAGING"

### Development Profile (Green)
- Clone default profile
- Name: "Development"
- Colors: Green tint
- Badge: "🟢 DEV"

**Auto-switching:** With the [ZSH config](https://github.com/YOUR_USERNAME/zshrc-config), profiles auto-switch based on directory!

## 🔧 Advanced Tips

### 1. iTerm2 Shell Integration

Enable shell integration for enhanced features:

```bash
curl -L https://iterm2.com/shell_integration/zsh \
-o ~/.iterm2_shell_integration.zsh
```

Then add to `.zshrc`:
```bash
source ~/.iterm2_shell_integration.zsh
```

Features:
- Command history
- Recent directories
- Upload/download files
- Badges with dynamic content

### 2. Dynamic Profiles

Create JSON profiles that load on startup:

```bash
mkdir -p ~/Library/Application\ Support/iTerm2/DynamicProfiles
```

### 3. Automatic Dark/Light Mode

Set up automatic theme switching:
- Preferences → Appearance → General
- ✅ **Automatically switch to light/dark theme**

## 🎭 Pairing with Other Tools

This iTerm2 config pairs perfectly with:

- ✅ [ZSH Configuration](https://github.com/YOUR_USERNAME/zshrc-config) - Nord-themed shell
- ✅ [Neovim Nord](https://github.com/nordtheme/vim) - Matching editor
- ✅ [Tmux Nord](https://github.com/nordtheme/tmux) - Terminal multiplexer

## 📖 Resources

- [iTerm2 Documentation](https://iterm2.com/documentation.html)
- [Nord Theme](https://www.nordtheme.com/)
- [Nord iTerm2](https://github.com/nordtheme/iterm2)
- [Nerd Fonts](https://www.nerdfonts.com/)

## 🐛 Troubleshooting

### Colors look wrong
- Make sure Nord theme is selected in Color Presets
- Check that "Minimum contrast" is set to default

### Icons not showing
- Install a Nerd Font (JetBrainsMono Nerd Font recommended)
- Make sure the font is selected in Text settings

### Status bar not working
- Enable in Preferences → Profiles → Session
- Add components in Configure Status Bar

### Transparency not working
- Check Window settings
- Ensure "Keep background colors opaque" is checked
- Restart iTerm2

## 🔄 Syncing Settings

To sync iTerm2 settings across machines:

1. **Enable preferences saving:**
   - Preferences → General → Preferences
   - ✅ Load preferences from a custom folder
   - Select: `~/Dropbox/iTerm2` (or any sync folder)
   - ✅ Save changes automatically

2. **Commit to this repo:**
   ```bash
   cp ~/Library/Preferences/com.googlecode.iterm2.plist ~/dotfiles-iterm/
   cd ~/dotfiles-iterm
   git add .
   git commit -m "Update iTerm2 preferences"
   git push
   ```

## 🤝 Contributing

Feel free to submit issues and enhancement requests!

## 📝 License

MIT License - Feel free to use and modify!

## 🙏 Credits

- [Nord Theme](https://www.nordtheme.com/)
- [iTerm2](https://iterm2.com/)
- [JetBrains Mono](https://www.jetbrains.com/lp/mono/)

---

Made with ❄️ and ☕
