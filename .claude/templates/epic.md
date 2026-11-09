---
# OKF frontmatter: keep only when .claude/docs-layout.yaml says `frontmatter: true` (docs-layout.md).
type: Epic
title: Epic <N> — <Title>
description: <one sentence: what the epic achieves>
status: draft
tags: [epic-<N>]
generated: {by: <human:id | tool/model>, at: <RFC 3339 datetime>}
---

# Epic <N> — <Title>

- **Status**: Planning
- **Stories**: --
- **Class**: <highest story class> (`~/.claude/templates/estimate.md`)
- **Initiative**: <ADR-NNNN, … — or none>
- **Design doc**: <`<design>/<slug>.md`, one per epic>
- **Merged**: --
- **Stable**: -- (the epic is done when it is stable in staging, which comes after merge)

## Summary

<One short paragraph each, in full sentences, for someone who hasn't read the code.>

**The problem today:** <what is wrong or missing, and who it affects>

**When this epic ships:** <what is different, in terms of product behavior or a number>

**Why now:** <what this unblocks, or what waiting costs>

## Architecture Diagram

```mermaid
graph TD
    %% Show the target architecture after this epic is complete
    A[Component A] --> B[Component B]
```

## Stories

| #   | Story         | File                               |
| --- | ------------- | ---------------------------------- |
| N.1 | <Story title> | [N.1-slug.md](../stories/N.1-slug.md) |
| N.2 | <Story title> | [N.2-slug.md](../stories/N.2-slug.md) |

## Key Changes

- <Major change or deliverable>
- <Major change or deliverable>

## Dependencies

- <Other epics or external requirements>

## Gold Standards

The reference each tier follows; stories carry the verbatim excerpts. A tier with no reference is a gap and needs an ADR before its stories start.

| Tier | Reference (`path:start-end`) | What it demonstrates | Gap |
| ---- | ---------------------------- | -------------------- | --- |
| <Repository> | <`path:start-end`> | <the shape to copy> | <none, or ADR-NNNN> |
| <Tests> | <`tests/path:start-end`> | <tier, double, doc block> | <none, or ADR-NNNN> |

## Gaps & Unknowns

Each item names a specific file, system, or decision and ends in a question, a story, or `checked: <evidence>`.

- **Assumptions:** <assumption → how verified>
- **Questions nobody asked:** <question — how the answer changes the epic>
- **Missing work:** <what no story covers yet → story N.M, or why it is out>
- **Case against this epic:** <the strongest argument, and the answer to it>

## Soak (Gate-and-soak epics, or any story with Operational surface ≥ 2)

- [ ] Every new cloud call has its permission/grant deployed (IAM, CI token, trust policy)
- [ ] Generated artifacts, lock files, and pinned versions agree across modules and environments
- [ ] Ran in staging with real data for <window> with no follow-up fix → set **Stable**

## Risks

| Risk     | Likelihood   | Impact       | Mitigation     |
| -------- | ------------ | ------------ | -------------- |
| [Risk 1] | Low/Med/High | Low/Med/High | [Mitigation 1] |
