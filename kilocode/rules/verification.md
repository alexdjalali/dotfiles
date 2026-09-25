## Verification

**Tests passing ≠ program working, and no completion claim without fresh evidence.**

- **Execute it:** CLI → run it · API → call it · UI → browser automation. Before claiming live E2E is impossible, try in order: a running local server → start the dev server and poll health (≤ 60 s) → a preview deploy (clean it up) → only then report unit-verified only, explicitly.
- **Check the output**, not just the exit code; compare external data against an independent fetch.
- **Evidence per claim:** tests pass = a fresh run, 0 failures · builds = exit 0 · bug fixed = the reproducing test passes · UI works = a browser snapshot. Name untested edge cases.
- About to say "should", "probably", or "done", or to commit → verify first. Fix every error found.

**Before reporting done:** hallucinated values · scope creep · silent fallbacks / swallowed errors · contradicting earlier decisions · wrong tool. Any hit → fix and re-verify.
