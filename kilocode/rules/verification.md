# Verification

**Core:** (1) tests passing ≠ program working — always execute. (2) No completion claim without **fresh evidence in the current message**.

## Execute, don't assume

- After tests pass / a refactor / a dep or config change / before marking "done": run the real thing. CLI → run it. API → call it. UI → drive it in a browser. Skip only for docs-only / test-only / pure internal refactor / config-only.
- Running without error ≠ correct output. If code processes external data, fetch it independently and compare — numbers and content must match.

## Evidence before claims

First ask: do these tests verify what matters, or only what was easy? Acknowledge untested edge cases — never claim full coverage with partial.

1. Identify the command that proves the claim. 2. Run it fresh (not cached). 3. Read the exit code + failure count. 4. State the claim **with** its evidence.

| Claim | Required evidence | Not enough |
|---|---|---|
| Tests pass | fresh run, 0 failures | "should pass" |
| Build succeeds | build exit 0 | "lint passed" |
| Bug fixed | reproducing test passes | "code changed" |
| UI works | browser snapshot / read | "API returns 200" |
| No perf regression | hot paths cache/memoize, no heavy imports, no redundant repeat work | "tests pass" |

**If you haven't run the command in this message, you cannot claim it passes.**

## Frontend

Any change to what the user sees requires **browser verification** — not just unit tests + typecheck. Stale bundles, layout, and wiring are invisible to unit tests. Report what you actually saw.

- **Live-target probe before any "I can't run live E2E" claim** — try, and record the outcome of, each tier: (1) an already-running local server (health check); (2) start the dev server yourself and poll its health endpoint for up to 60 s; (3) a preview deploy on a detected backend (Vercel, Fly, Netlify, Cloudflare, …) after its auth check — clean up deploys made only for verification; (4) only then fall back to unit-verified, and say so explicitly.
- **E2E = interaction, not load:** snapshot → click the primary action → re-snapshot → confirm the new state. `curl` / fetched HTML, API 200s, reading source, and unit tests are not browser evidence.

## When execution fails after tests pass

It's a real bug: fix → re-run the tests → re-execute → add a test that catches this failure type.

## Fix all errors

Fix every verification error before claiming done — no exceptions. In a plan-only / read-only mode, present the issues and proposed fixes instead of applying them.

## Stop signals — verify NOW

About to say "should / probably", express "Done!", commit, or mark complete → run verification first.

## Five failure modes (self-check before "done")

- **Hallucinated actions** — invented paths / env vars / IDs / function names / library APIs / URLs. Never invent — confirm or ask.
- **Scope creep** — diff touches files or behavior outside the request; bundled "while I'm here" cleanups. Apply the lineage test.
- **Cascading errors** — a failure caught / wrapped / swallowed so it hides the root cause; silent fallbacks (`except: return []`).
- **Context loss** — diff contradicts earlier decisions, the plan, or the project's standards.
- **Tool misuse** — wrong tool for the job, or the right tool with wrong params.

Any mode flagged → fix and re-run; do not claim done.
