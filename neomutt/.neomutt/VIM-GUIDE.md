# Neomutt Vim Keybindings Guide

## Visual Improvements

✨ **Nord color scheme** (arctic-inspired, matches terminal and editor)
📎 **Unicode symbols** for attachments and threads
📊 **Mini-index above messages** (split view like vim)
│  **Sidebar divider** with unicode character
🧵 **Thread indicators** in message list

## Vim-Style Navigation

### Basic Movement (Just Like Vim!)

**In Index (message list):**
- `j` / `k` - Move down/up (standard vim)
- `gg` - Go to first message
- `G` - Go to last message
- `H` - Top of page
- `M` - Middle of page
- `L` - Bottom of page
- `Ctrl-u` - Half page up
- `Ctrl-d` - Half page down

**In Pager (reading message):**
- `j` - Scroll down one line
- `k` - Scroll up one line
- `gg` - Top of message
- `G` - Bottom of message
- `H` / `M` / `L` - Top/Middle/Bottom of page
- `h` - Exit message (back to index)
- `l` - Display message (from index)
- `J` - Next message
- `K` - Previous message

### Search (Vim-Style)

- `/` - Search forward
- `?` - Search backward
- `n` - Next search result
- `N` - Previous search result

### Thread Folding (Like Vim Folds!)

- `Space` - Toggle current thread
- `za` - Toggle thread (vim fold command!)
- `zR` - Open all threads
- `zM` - Close all threads

### Window Navigation (Vim hjkl style!)

**Navigate like vim motions:**
- `Ctrl-h` - Go left (back to index / toggle sidebar)
- `Ctrl-l` - Go right (open message / toggle sidebar)
- `Ctrl-j` - Go down (next mailbox in sidebar)
- `Ctrl-k` - Go up (previous mailbox in sidebar)

**Additional navigation:**
- `Ctrl-o` - Open selected mailbox from sidebar
- `Ctrl-b` or `B` - Toggle sidebar visibility
- `i` - Back to index (from pager)

### Actions (Vim-Style)

- `dd` - Delete message (like vim delete line)
- `u` - Undelete message (like vim undo)
- `m` - Compose new message
- `r` - Reply
- `R` - Reply all (group reply)
- `f` - Forward

### Quitting (Vim-Style)

- `q` - Quit (like `:q` in vim)
- `Q` - Quit without confirmation
- `ZZ` - Save and quit (like vim!)
- `ZQ` - Quit without saving (like vim!)

### Quick Folder Navigation

- `gi` - Go to Inbox
- `gs` - Go to Sent
- `gd` - Go to Drafts
- `gt` - Go to Trash
- `ga` - Go to All Mail
- `c` - Change folder (then type or select)

### Account Switching

- `F2` or `,g` - Switch to Gmail
- `F3` or `,t` - Switch to Georgia Tech

## Visual Elements Explained

### Index Format
```
   # Z 📎 Date  From/To          Subject              🧵#
   1 N 📎 02/03 John Doe         Meeting tomorrow     🧵3
   2 O   02/02 Jane Smith       Re: Project update
   3 F   02/01 Team             Important!           🧵5
```

**Symbols:**
- `N` = New message
- `O` = Old (read) message
- `F` = Flagged/starred
- `D` = Deleted
- `📎` = Has attachments
- `🧵` = Part of a thread (number = messages in thread)

### Status Bar

Shows at bottom:
```
─ Inbox 42 messages (3 new) (1 to delete) (2 tagged) > 25% ─
```

### Pager Header

When reading a message:
```
─ 5/42: John Doe  Meeting tomorrow  50% ─
```

## Tips for Vim Users

1. **Split View**: The mini-index above messages mimics vim splits
   - Use `j/k` in pager to scroll through message
   - Use `J/K` to jump between messages

2. **Visual Mode**: Use `t` to tag messages (like visual select)
   - Tag with `t`, then apply action with `;` prefix
   - Example: `t t t ;d` = tag 3 messages, then delete all

3. **Macros**: Use `macro` feature for complex operations
   - Already configured: `A` for archive
   - Add your own in `~/.neomuttrc`

4. **Composing in Vim**: When you press `m`, Neovim opens
   - Full vim power for writing emails
   - `:wq` to finish, `:cq` to cancel

5. **Search Patterns**: Like vim patterns
   - `~f alice` = from alice
   - `~s meeting` = subject contains meeting
   - `~b report` = body contains report

## Customization

All keybindings are in `~/.neomuttrc` under "Keybindings" section.

To add your own vim-like binding:
```
bind index,pager KEY FUNCTION
```

Example:
```
bind index,pager \Cl redraw-screen  # Ctrl-l like vim
```

## Color Scheme

Using **Nord** theme (arctic-inspired, consistent with zsh/nvim/iTerm):
- Frost (cyan/teal) for new messages
- Aurora yellow for important/flagged items
- Aurora red for errors/deleted
- Aurora green for replied messages
- Polar Night for backgrounds, Snow Storm for foregrounds

To customize, edit `~/.neomutt/nord.neomuttrc`.

## Quick Reference Card

```
┌─ MOVEMENT ──────┬─ ACTIONS ──────┬─ NAVIGATION ────┐
│ j/k    up/down  │ m      new     │ gi     inbox    │
│ gg/G   top/bot  │ r      reply   │ gs     sent     │
│ H/M/L  H/M/L    │ R      reply all│ gd     drafts   │
│ ^u/^d  pg up/dn │ f      forward │ gt     trash    │
│ h      back     │ dd     delete  │ c      change   │
│ l      open     │ u      undelete│ /      search   │
│ J/K    msg up/dn│ A      archive │ ^b     sidebar  │
│ Space  toggle   │ F      flag    │ F2/F3  account  │
└─────────────────┴────────────────┴─────────────────┘
```

Happy vim-style emailing! 📧
