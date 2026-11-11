#!/usr/bin/env bash
# Seeds a repo whose uncommitted change to page() drops the last item of each page.
set -euo pipefail
cat >pager.py <<'PY'
"""Pagination over an in-memory list."""


def page(items: list[str], number: int, size: int) -> list[str]:
    """Return page `number` (1-based) of `items`, `size` items per page."""
    start = (number - 1) * size
    return items[start : start + size]
PY
git init -q
git add -A
git -c user.email=eval@example.invalid -c user.name=eval commit -qm "feat: add page()"
cat >pager.py <<'PY'
"""Pagination over an in-memory list."""


def page(items: list[str], number: int, size: int) -> list[str]:
    """Return page `number` (1-based) of `items`, `size` items per page."""
    if number < 1 or size < 1:
        raise ValueError("number and size must be positive")
    start = (number - 1) * size
    end = start + size - 1
    return items[start:end]
PY
