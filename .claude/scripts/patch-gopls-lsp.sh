#!/usr/bin/env bash
# patch-gopls-lsp.sh
#
# Ensures the gopls LSP plugin (Piebald "claude-code-lsps" marketplace) is
# configured so Claude Code's LSP tool does NOT report "stale LSP" on large
# multi-module go.work workspaces (e.g. TechAI/bloodhound-search-platform,
# a 35-module workspace whose gopls InitialWorkspaceLoad is ~14s+).
#
# Two knobs, both applied to the plugin's cached .lsp.json:
#   1. startupTimeout  -> Claude waits for gopls to finish loading before
#                         querying it (documented .lsp.json field, CC 2.1.205+).
#   2. directoryFilters -> gopls skips watching/scanning non-Go trees, cutting
#                         load time and post-edit reload churn. Only dirs that
#                         are NEVER Go source in ANY project are excluded, since
#                         this config is global to every Go project.
#
# Idempotent: only rewrites the file when the content actually changes.
# Re-applies itself after plugin auto-updates (FORCE_AUTOUPDATE_PLUGINS wipes
# cache edits) because it runs from a SessionStart hook. Safe no-op when jq or
# the gopls plugin is absent.
set -euo pipefail

command -v jq >/dev/null 2>&1 || exit 0

# Excludes must be safe for EVERY Go project (global config), so only list
# directory names that are never Go source. `**/` matches at any depth.
FILTERS='["-**/node_modules","-**/.venv","-**/venv","-**/.git","-**/.worktrees","-**/.mypy_cache","-**/.pytest_cache","-**/.ruff_cache"]'
STARTUP=180000   # 3 min; comfortably above a cold gopls workspace load
SHUTDOWN=15000

shopt -s nullglob
for f in "$HOME"/.claude/plugins/cache/claude-code-lsps/gopls/*/.lsp.json; do
  tmp="$(mktemp)"
  if jq \
      --argjson filters "$FILTERS" \
      --argjson st "$STARTUP" \
      --argjson sh "$SHUTDOWN" '
        .go.startupTimeout      = $st
      | .go.shutdownTimeout     = $sh
      | .go.initializationOptions = ((.go.initializationOptions // {}) + {directoryFilters: $filters})
      | .go.settings            = ((.go.settings // {}) + {directoryFilters: $filters})
      ' "$f" > "$tmp" 2>/dev/null; then
    if ! cmp -s "$tmp" "$f"; then
      cat "$tmp" > "$f"
      echo "patch-gopls-lsp: updated $f" >&2
    fi
  fi
  rm -f "$tmp"
done

exit 0
