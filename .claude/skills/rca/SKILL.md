---
model: opus
description: Diagnose the root cause of one or more bugs and record a diagnosis-only, file:line-cited report in docs/spec/rca/. Use when related bugs need a written diagnosis before fixing, or someone else will fix it.
---

The persistent, evidence-cited sibling of `/investigate` (which finds the cause live and fixes it): `/rca` captures the causal chain with `file:line` proof so a fix can be built from it. **Input:** one symptom or a cluster of related ones. **Output:** `docs/spec/rca/<slug>.md` from `~/.claude/templates/rca.md`. NEVER apply a fix here — diagnosis only.

## Steps

1. **Characterize** each symptom — the condition under which it happens vs doesn't. Can't reproduce it? Say so and mark that cause "not yet pinned".
2. **Trace** control/data flow from trigger to symptom (`codegraph_callers` / `codegraph_impact` + Semble), then read the actual code. NEVER pattern-match a plausible cause — the code's behavior is truth; your mental model is a guess.
3. **Name the mechanism** (e.g. "split-brain authorization", "missing soft-delete cascade"), not just the location.
4. **Blast radius** — other symptoms the same cause explains, and latent bugs found along the way.
5. **Sketch the fix** — the layer to change plus the defense-in-depth layers to harden — without applying it.
6. **Write** `docs/spec/rca/<slug>.md` from the template.

## Rules

- NEVER state a root cause without `file:line` evidence — an unproven cause is labeled "not yet pinned", with the capture step needed to confirm it.
- One root cause per numbered finding; a shared cause is called out as shared.

## Next Step

Ask:

> Diagnosis recorded. Fix it?
> - `/fix <slug>` — quick-lane fix (reproducing test first, revert-test proof)
> - `/spec` — larger fix: plan → implement → verify (bugfix lane)
> - Done — diagnosis only

Run `/fix` via `Skill()` if chosen; `/spec` is suggested for the user to type — never invoked.
