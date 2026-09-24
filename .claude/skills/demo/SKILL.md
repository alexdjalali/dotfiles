---
model: opus
description: Write an end-to-end demo walkthrough (docs/spec/demos/<slug>.md + optional .sh), every command verified and dry-run against the real system. Use after a user-visible epic ships, as durable proof it works.
argument-hint: <epic or story>
---

The persistent, shareable counterpart to the bundled `/verify` (which exercises a change live but leaves no artifact): proof the feature works through the **real system, end to end**. **Input:** a shipped epic or story. **Output:** `docs/spec/demos/<slug>.md` from `~/.claude/templates/demo.md`, plus `docs/spec/demos/<slug>.sh` when a scripted run helps.

## Steps

1. **Pick the flow and surface** — the user-visible flow, driven through the real path a client uses (frontend, API via the gateway, or CLI). Drive the real system, never a mock; label any offline fallback explicitly.
2. **Verify every command, endpoint, port, flag, path, and credential** against the code and config (CLAUDE.md, `configs/`, the actual routes). NEVER invent one.
3. **Write the walkthrough** — "What you'll show" (the arc), a step-count summary table, prerequisites, then numbered Parts, each a copy-pasteable command or call with the output to expect.
4. **Dry-run it** when a target is reachable (Read `~/.claude/rules/browser-automation.md` and run its live-target probe) and record the real output. A step you couldn't run is marked unverified — NEVER present invented output as real.
5. **Cleanup** and a **troubleshooting** table (symptom → cause → fix) for the failures you hit while dry-running.
6. **Write** the `.md`; add the `.sh` (`set -euo pipefail`, echo each step, assert expected output) when a scripted run helps.

## Next Step

Demo recorded → suggest `/github` to open a PR with it (user-typed), or stop here.
