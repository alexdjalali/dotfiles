# Multi-Account Neomutt Setup

## Accounts Configured

1. **Gmail**: alex.djalali@gmail.com (App Password)
2. **Georgia Tech**: adjalali3@gatech.edu (OAuth2)

## Initial Setup - IMPORTANT!

Before using your GT account, you must authorize OAuth2 access:

```bash
~/.neomutt/authorize_gatech.sh
```

This will:
1. Open your browser to Microsoft login
2. Prompt you to sign in with adjalali3@gatech.edu
3. Ask for 2FA (use your authenticator app/hardware token)
4. Request permission for neomutt to access your email
5. Save the authorization tokens

**You only need to do this once!** The tokens will auto-refresh.

## Switching Between Accounts

### In Neomutt:

**Function Keys:**
- `F2` - Switch to Gmail
- `F3` - Switch to Georgia Tech

**Quick Shortcuts:**
- `,g` - Switch to Gmail
- `,t` - Switch to GT (Tech)

### What Happens When Switching:
- Loads account-specific settings
- Changes IMAP/SMTP servers
- Updates folder structure
- Changes "From" address
- Updates status bar

## Account-Specific Features

### Gmail (F2 / ,g)
- **Folders**: Inbox, Sent Mail, Drafts, Trash, Spam, All Mail, Starred
- **Archive**: Press `A` to archive (removes from Inbox)
- **Labels**: Gmail labels appear as folders

### Georgia Tech (F3 / ,t)
- **Folders**: Inbox, Sent, Drafts, Deleted, Junk, Archive
- **Authentication**: OAuth2 (tokens auto-refresh)
- **Calendar**: Use GT web interface or Outlook

## Composing from Specific Account

When composing a new message:
1. Switch to the account you want to send from (F2 or F3)
2. Press `m` to compose
3. The email will be sent from that account

**Tip**: Check the status bar to see which account is active!

## Default Account

Gmail is the default account when neomutt starts. To change this:
- Edit `~/.neomuttrc`
- Change `source ~/.neomutt/account.gmail` to `source ~/.neomutt/account.gatech`

## Troubleshooting

### GT OAuth2 Issues

**Token Expired:**
```bash
~/.neomutt/authorize_gatech.sh
```

**Can't Connect:**
1. Check GT email works in web browser
2. Verify 2FA is set up
3. Re-authorize: `~/.neomutt/authorize_gatech.sh`
4. Check GT OIT status page for outages

**Authentication Failed:**
- Tokens are stored in `~/.neomutt/gatech.tokens`
- If corrupted, delete and re-authorize
- Contact GT OIT if IMAP is disabled for your account

### Gmail Issues

**Can't Connect:**
- Verify app password: `cat ~/.neomutt/gmail.pass`
- Regenerate if needed: https://myaccount.google.com/apppasswords

### General

**Wrong Account:**
- Check status bar (top of screen)
- Press F2 or F3 to switch
- Restart neomutt if needed

**Folders Missing:**
- Some folders take time to sync on first load
- Press `c` then `?` to see all available folders
- Press `Tab` to toggle between subscribed and all folders

## File Structure

```
~/.neomutt/
├── account.gmail          # Gmail account settings
├── account.gatech         # GT account settings
├── gmail.pass             # Gmail app password
├── gatech.tokens          # GT OAuth2 tokens (auto-updated)
├── mutt_oauth2.py         # OAuth2 helper script
└── authorize_gatech.sh    # GT authorization script
```

## Advanced: Automatic Account Switching

Want neomutt to automatically use the right account based on folder?

Add to `~/.neomuttrc`:
```
folder-hook 'gmail.com' 'source ~/.neomutt/account.gmail'
folder-hook 'office365.com' 'source ~/.neomutt/account.gatech'
```

## Tips

1. **Status Bar Shows Account**: Look at the top of neomutt - shows "Gmail" or "GT"

2. **Reply from Same Account**: When replying, neomutt uses the account that received the email (checks To: field)

3. **Quick Switch Before Send**: Press F2/F3 even while composing to change send-from address

4. **Search Across Accounts**: Switch accounts and use `/` to search each separately

5. **Archive Strategies**:
   - Gmail: Press `A` to archive
   - GT: Press `s` then select "Archive" folder

## Getting Help

- General keybindings: See `~/.neomutt/QUICKSTART.md`
- Press `?` in neomutt for all commands
- GT email issues: Contact OIT (oit.gatech.edu)
- Gmail issues: Regenerate app password

Happy multi-account emailing! 📧🐝
