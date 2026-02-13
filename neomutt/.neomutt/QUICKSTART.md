# Neomutt Quick Start Guide

## Launching Neomutt

**From anywhere:**
```bash
neomutt
```

**From Neovim:**
- Press `<leader>lm` to open neomutt in a terminal

## Essential Keybindings

### Navigation
- `j/k` - Move up/down in message list
- `gg` - Go to first message
- `G` - Go to last message
- `Enter` - Open message
- `i` - Return to inbox from message view
- `c` - Change folder
- `q` - Quit (from index) or return to index (from message)

### Quick Folder Access
- `gi` - Go to Inbox
- `gs` - Go to Sent Mail
- `gd` - Go to Drafts
- `gt` - Go to Trash
- `ga` - Go to All Mail

### Reading & Managing
- `d` - Delete message (moves to Trash)
- `u` - Undelete message
- `A` - Archive message (removes from Inbox, keeps in All Mail)
- `N` - Mark as new/unread
- `s` - Save message to folder
- `F` - Flag message (star)
- `/` - Search messages
- `l` - Limit/filter messages (e.g., `~f bob` for messages from bob)

### Composing
- `m` - New message
- `r` - Reply to sender
- `R` - Reply to all
- `f` - Forward message
- `e` - Edit draft

### When Composing (in Neovim)
1. Write your message in Neovim
2. Save and quit (`:wq`)
3. Choose to send `y`, edit again `e`, or postpone `p`

### Sidebar
- `B` - Toggle sidebar visibility
- `Ctrl+k` - Previous mailbox in sidebar
- `Ctrl+j` - Next mailbox in sidebar
- `Ctrl+o` - Open selected mailbox

### Threading
- `Space` - Collapse/expand thread
- `Ctrl+r` - Read entire thread

## Search Syntax

Use `l` (limit) or `/` (search) with these patterns:
- `~f alice` - From alice
- `~t bob` - To bob
- `~s meeting` - Subject contains "meeting"
- `~b report` - Body contains "report"
- `~N` - New messages
- `~F` - Flagged messages
- `~d >1w` - Older than 1 week
- Combine: `~f alice ~s project` - From alice with "project" in subject

Press `all` to clear limits and show all messages.

## Gmail-Specific

### Archive vs Delete
- **Archive (`A`)**: Removes from Inbox, keeps in All Mail (Gmail style)
- **Delete (`d`)**: Moves to Trash folder

### Labels
Gmail labels appear as folders in the sidebar. You can:
- Move messages to labels: `s` then type `=[Gmail]/LabelName`
- View label: `c` then select from list

## Tips

1. **Threading**: Messages are automatically threaded. Use Space to collapse/expand.

2. **Searching**: Press `/` to search, `n` for next, `N` for previous match.

3. **Bulk Operations**:
   - `t` to tag messages
   - `;` then action (like `d`) to apply to all tagged

4. **Composing HTML**: Neomutt sends plain text by default (better for email!)

5. **Attachments**:
   - When composing, press `a` to attach files
   - When reading, use `v` to view attachments list, Enter to save

6. **URL Handling**: Press `Ctrl+b` in message view to extract URLs (requires urlview)

7. **Speed**: First load takes a moment as it downloads headers. After that, it's cached and super fast!

## Configuration Files

- `~/.neomuttrc` - Main configuration
- `~/.neomutt/aliases` - Email aliases/contacts
- `~/.neomutt/gmail.pass` - Your app password (keep secure!)

## Adding Contacts

Edit `~/.neomutt/aliases`:
```
alias bob Bob Smith <bob@example.com>
alias alice Alice Jones <alice@example.com>
```

Then when composing, type `bob` and it expands to the full address!

## Troubleshooting

### Can't Connect
- Check your app password is correct: `cat ~/.neomutt/gmail.pass`
- Verify 2FA is enabled on Gmail
- Regenerate app password at: https://myaccount.google.com/apppasswords

### Slow Performance
- First sync takes time. Subsequent loads use cache.
- Consider using `mbsync` or `offlineimap` for offline mail.

### Colors Look Wrong
- Config uses Nord theme (sourced from `~/.neomutt/nord.neomuttrc`)
- Edit colors in `~/.neomutt/nord.neomuttrc`

## Advanced: Offline Mail (Optional)

For offline access and faster performance, you can set up `mbsync`:
```bash
brew install isync
```

Ask Claude to help configure offline sync!

## Getting Help

- Press `?` in neomutt to see all keybindings
- `:help` in neomutt for built-in help
- Edit `~/.neomuttrc` to customize anything

Happy emailing! 📧
