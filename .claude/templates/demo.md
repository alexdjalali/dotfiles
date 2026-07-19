# <Epic / Story> — Demo Walkthrough

<One or two sentences: what this demonstrates and how — through the real system
(which surface: frontend, API via the gateway, CLI). State plainly that the flow
is real (real auth, real storage, real messaging), not mocked.>

> **Run on:** <branch / env>. <Any precondition that makes the demo run clean —
> a fix on this branch, a seed step, a token lifetime.>

## What you'll show

<The narrative arc in 3–6 beats — bring the system up, seed, authenticate, run
the payoff flow, verify the result.>

**The whole flow is <N> steps:**

| # | Command / call | Purpose | Expect |
|---|----------------|---------|--------|
| 1 | `<cmd or METHOD /path>` | <why> | <observable result> |

---

## Prerequisites

- <tools installed, services up, creds present — each verified against the repo>

## Part 1 — <bring it up>

```bash
<real command>
```

<What to watch for — the banner, the health line, the console URL.>

## Part 2 — <the payoff>

```bash
<real command / call, with the output to expect>
```

## Cleanup

```bash
<teardown — delete the demo artifacts, bring the stack down>
```

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| <error seen while dry-running> | <root cause> | <the command that fixes it> |

<!-- Companion script: docs/spec/demos/<slug>.sh runs this same flow
     non-interactively (set -euo pipefail; echo each step; assert expected output). -->
