## Verification

**Tests passing ≠ program working, and no completion claim without fresh evidence from this turn.**

- **Execute it:** CLI → run it · API → call it · UI → browser automation (`browser-automation.md` — run its live-target probe before ever claiming "can't run E2E"). Skip only for docs-, test-, or config-only changes and internal refactors with no entry point.
- **Check the output**, not just the exit code — processing external data? Fetch it independently and compare.
- **Evidence per claim:** "tests pass" = a fresh run with 0 failures · "builds" = exit 0 · "bug fixed" = the reproducing test passes · "UI works" = a browser snapshot. Untested edge cases → say so; never claim full coverage from partial.
- **Stop signals** — about to say "should"/"probably", "Done!", commit, or mark complete → verify first.
- **Fix every error you find** (in `/spec`, without asking; in plan mode, propose instead). Execution fails after tests pass → it's a real bug: fix it and add a test for that failure type.

**Before reporting done, check the five failure modes:** hallucinated values (paths, env vars, IDs, APIs) · scope creep (lineage test) · cascading errors (silent fallbacks, swallowed failures) · context loss (contradicts the plan or an earlier decision) · tool misuse. Any hit → fix and re-verify.
