---
# OKF frontmatter: keep only when .claude/docs-layout.yaml says `frontmatter: true` (docs-layout.md).
type: Design
title: <Feature / Subsystem> — Design
description: <one sentence: what the design covers>
status: draft
generated: {by: <human:id | tool/model>, at: <RFC 3339 datetime>}
---

# <Feature / Subsystem> — Design

> **Scope:** <what this design covers, and explicit non-goals>.
> **Reflects:** the code as of <YYYY-MM-DD> (<relevant epics/stories>).
> **Governing:** ADR-<NNNN> (the decision), `<arch>/<slug>.md` (diagrams; the `arch` layout path, docs-layout.md).

## TL;DR

<The end-state design in 3–6 numbered steps — the reader should grasp the whole
shape from this section alone.>

## Context & constraints

<Current state and the problem being solved. Hard constraints that bound the
solution (external contracts, security, correctness invariants, physics). Explicit
non-goals so scope is unambiguous.>

## The design

```mermaid
%% One diagram per concern (sequence / component / flow), derived from real code.
sequenceDiagram
    participant A as <...>
    participant B as <...>
    A->>B: <...>
```

<Narrative, stage by stage: what drives each stage, where the seams/interfaces
are, what is config-selected (`Kind`/factory), what resiliency is built in, and
what is deliberately deferred.>

### Code generation

<The contracts this design is derived from (proto / OpenAPI / schema / DI graph /
templates), the generator that owns each, where output lands, and the drift check.
"None" is a decision — say why the code can't be generated.>

### Operability

<Per external dependency: timeout, retry policy (transient codes only), circuit
breaker / bulkhead, and the decorator order. The new error codes. The logs,
metrics, and spans added; health/readiness; shutdown and drain. How it degrades.>

### Cross-cutting and rollout

<The layers from `cross-cutting.md` this design reaches, each with its owner stage. The
deploy order, manual steps, version-skew window, and rollback.>

### Configuration

<The config slice each layer owns, the `Kind`s and their stub default, new fields
with their fail-safe `base` values, and what lives in env overlays vs secrets.>

## State / data model

```
<FSM or schema, when the design has stateful entities — e.g. document status:
pending ─▶ processing ─▶ indexed / failed>
```

## Alternatives considered

| Option | Why not chosen |
| --- | --- |
| <alt> | <trade-off> |

## Open questions

- <unresolved decision that needs a ruling before/while building>

## References

- ADRs: <ADR-NNNN …> · Arch: `<arch>/<slug>.md` · Stories: <…>
