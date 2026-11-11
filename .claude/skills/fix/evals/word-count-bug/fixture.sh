#!/usr/bin/env bash
# Seeds a one-module Python repo whose word_count miscounts repeated spaces.
set -euo pipefail
mkdir -p tests
touch tests/__init__.py
cat >textutil.py <<'PY'
"""Text helpers."""


def word_count(text: str) -> int:
    """Return the number of whitespace-separated words in text."""
    return len(text.split(" "))
PY
cat >tests/test_textutil.py <<'PY'
"""Behavior tests for textutil.py."""

import unittest

from textutil import word_count


class WordCountTest(unittest.TestCase):
    """word_count counts words separated by whitespace."""

    def test_two_words(self) -> None:
        """Two words separated by one space count as two."""
        self.assertEqual(word_count("hello world"), 2)


if __name__ == "__main__":
    unittest.main()
PY
git init -q
git add -A
git -c user.email=eval@example.invalid -c user.name=eval commit -qm "init"
