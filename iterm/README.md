# iTerm2

iTerm2 preferences for these dotfiles, with the Catppuccin Mocha palette used
by the shell, tmux and Neovim.

## What's included

- `com.googlecode.iterm2.plist`: the full iTerm2 preferences (XML plist). Its one
  profile, `Default`, uses the Catppuccin Mocha colours and JetBrainsMono Nerd
  Font Mono 13. The fonts come from the Brewfile's `font-*-nerd-font` casks.
- `catppuccin-mocha.itermcolors`: the colour preset on its own, to import into
  another profile (Settings > Profiles > Colors > Color Presets > Import).
- `Nord.itermcolors`: an alternative preset.
- `DynamicProfiles/web.json`: a `Web` profile of type Web Browser, inheriting
  from `Default`. `install.sh` links it into
  `~/Library/Application Support/iTerm2/DynamicProfiles/`, and the plist makes it
  the default browser profile, so web links iTerm opens land in it.

The zsh side (`zsh/conf.d/08-iterm.zsh`) adds shell integration, badges
(directory, git branch, tool versions), directory-based tab colours and window
titles. `install.sh` downloads the shell integration script.

## Use these preferences

1. iTerm > Settings > General > Settings: enable **Load settings from a custom
   folder or URL** and choose `~/dotfiles/iterm` (wherever the repo is cloned).
2. Set **Save changes** to *Automatically*, or to *Manually* and use
   **Save Now**, so changes made in iTerm land back in this folder.
3. Restart iTerm.

## Web browser

iTerm2 3.6+ can run browser sessions in tabs and splits next to terminals
(<https://iterm2.com/documentation-web.html>). Full functionality needs the
separately signed browser plugin: download it from
<https://iterm2.com/browser-plugin.html>, unzip it and move
`iTermBrowserPlugin.app` to `/Applications`. iTerm finds it there on its own.
Then open a browser with **Profiles > Web**.

## Regenerate the file

iTerm writes the file itself when **Save Now** is pressed with the custom folder
set. To rebuild it from the preferences iTerm is using right now, export the
domain and convert it to XML:

```bash
defaults export com.googlecode.iterm2 ~/dotfiles/iterm/com.googlecode.iterm2.plist
plutil -convert xml1 ~/dotfiles/iterm/com.googlecode.iterm2.plist
plutil -lint ~/dotfiles/iterm/com.googlecode.iterm2.plist
```

The tracked copy leaves out the machine-local `NoSync*` keys, which iTerm itself
never saves to a custom folder, and dynamic profiles, which iTerm loads from
`~/Library/Application Support/iTerm2/DynamicProfiles`. Remove those from a raw
export before committing it. `tests/install/state_test.sh` checks that the file
is a valid plist and has every profile the zsh config switches to.
