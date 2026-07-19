---
model: opus
description: Write an end-to-end demo walkthrough (script + companion .sh) in docs/spec/demos/
argument-hint: <epic or story>
---

Produce a runnable demo of a shipped epic/story in `docs/spec/demos/` using `~/.claude/templates/demo.md`, plus an optional companion `.sh` that runs the same flow non-interactively.

A demo proves the feature works through the **real system, end to end** -- the persistent, shareable counterpart to the `/verify` skill (which exercises a change live but doesn't leave an artifact). Model: `demos/epic-4-demo.md` + `demos/epic-4-demo.sh`.

## Steps

1. Identify the user-visible flow to demo (an epic or story) and the surface to drive it through -- frontend, API via the gateway, or CLI. Prefer the real path a client uses; label any offline fallback as such.
2. **Verify every command, endpoint, port, flag, and credential against the codebase** (CLAUDE.md, `configs/`, the actual routes). Never invent one.
3. Write the walkthrough: "What you'll show" (the arc), a step-count summary table, prerequisites, then numbered Parts with real commands and the output to expect at each step.
4. Add **cleanup** and a **troubleshooting** table (symptom -> cause -> fix) for the failure modes you hit while dry-running.
5. **Dry-run the flow** if a target is reachable (follow the live-target probe in the verification rules); record real output. If you couldn't run a step, mark it unverified -- don't present invented output as real.
6. Write `docs/spec/demos/<slug>.md`; add `docs/spec/demos/<slug>.sh` (`set -euo pipefail`, echo each step, assert expected output) when a scripted run helps.

## Rules

- NEVER invent a command, flag, path, port, or credential -- confirm each against the code/config
- NEVER present unverified output as real -- mark steps you couldn't execute
- Drive the real system (through the gateway/CLI), not a mock, unless an offline fallback is explicitly labeled
- Keep it copy-pasteable: every step is a command or call with an expected result

## Next Step

Ask:

> Demo recorded.
> - `/github` -- open a PR including the demo
> - Done -- demo only
