---
model: opus
description: Diagnose the root cause of one or more bugs and record it in docs/spec/rca/
---

Investigate a defect (or a cluster of related defects) to root cause and record a **diagnosis-only** report in `docs/spec/rca/` using `~/.claude/templates/rca.md`.

This is the persistent, evidence-cited sibling of `/debug`: `/debug` finds the cause live and fixes it; `/rca` captures the causal chain with `file:line` proof so a bugfix plan can be built from it. Use `/rca` when several related bugs need a written diagnosis before anyone fixes them, or when the fix will be someone else's plan.

## Steps

1. Reproduce or precisely characterize each symptom -- the condition under which it happens vs. doesn't. If it can't be reproduced, say so and mark that cause "not yet pinned."
2. Trace control/data flow from trigger to symptom with `codegraph_callers` / `codegraph_impact` + Semble, then read the actual code. Every causal claim carries `file:line` evidence.
3. Name the mechanism (e.g. "split-brain authorization", "missing soft-delete cascade") -- not just the location.
4. Note blast radius: other symptoms the same cause explains, and latent bugs found while investigating.
5. Sketch the fix (the layer to change + the defense-in-depth layers to harden) -- but DO NOT apply it.
6. Write `docs/spec/rca/<slug>.md` from the template.

## Rules

- NEVER apply a fix in this command -- diagnosis only; hand off to `/fix` or `/spec`
- NEVER state a root cause without `file:line` evidence -- an unproven cause is labeled "not yet pinned" with the capture step needed to confirm it
- NEVER pattern-match a plausible cause -- trace the actual flow (meta-debugging: the code's behavior is truth, your mental model is a guess)
- One root cause per numbered finding; a shared cause is called out as shared

## Next Step

Ask:

> Diagnosis recorded. Fix it?
> - `/fix <slug>` -- quick-lane fix (reproducing test first, revert-test proof)
> - `/spec` -- larger fix: plan -> implement -> verify (bugfix lane)
> - Done -- diagnosis only

Suggest the chosen command for the user to run -- never auto-invoke `/spec` (the user must type it).
