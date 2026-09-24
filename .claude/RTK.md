# RTK - Rust Token Killer

Token-optimized CLI proxy (60-90% savings on dev operations). A Claude Code hook rewrites Bash commands transparently (`git status` → `rtk git status`, 0 tokens overhead) — run commands normally.

**Meta commands** (always call `rtk` directly): `rtk gain` (token-savings analytics) · `rtk gain --history` (command history with savings) · `rtk discover` (missed opportunities in Claude Code history) · `rtk proxy <cmd>` (raw command, no filtering — for debugging).

**Verify the install:** `rtk --version` (shows `rtk X.Y.Z`), `rtk gain` works (not "command not found"), `which rtk`. ⚠️ **Name collision:** if `rtk gain` fails, you may have reachingforthejack/rtk (Rust Type Kit) installed instead.
