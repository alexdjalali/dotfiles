# Verification

**Core:** (1) tests passing ≠ program working — always execute. (2) No completion claim without **fresh evidence in the current message**.

## Execute, don't assume

- After tests pass / a refactor / a dep or config change / before marking "done": run the real thing. CLI → run it. API → call it. UI → drive it in a browser. Skip only for docs-only / test-only / pure internal refactor / config-only.
- Running without error ≠ correct output. If code processes external data, fetch it independently and compare — numbers and content must match.

## Evidence before claims

1. Identify the command that proves the claim. 2. Run it fresh (not cached). 3. Read the exit code + failure count. 4. State the claim **with** its evidence.

| Claim | Required evidence | Not enough |
|---|---|---|
| Tests pass | fresh run, 0 failures | "should pass" |
| Build succeeds | build exit 0 | "lint passed" |
| Bug fixed | reproducing test passes | "code changed" |
| UI works | browser snapshot / read | "API returns 200" |

**If you haven't run the command in this message, you cannot claim it passes.**

## Frontend

Any change to what the user sees requires **browser verification** — not just unit tests + typecheck. Stale bundles, layout, and wiring are invisible to unit tests. Report what you actually saw.

## Stop signals — verify NOW

About to say "should / probably", express "Done!", commit, or mark complete → run verification first.

## Five failure modes (self-check before "done")

- **Hallucinated actions** — invented paths / env vars / IDs / function names / library APIs / URLs. Never invent — confirm or ask.
- **Scope creep** — diff touches files or behavior outside the request; bundled "while I'm here" cleanups. Apply the lineage test.
- **Cascading errors** — a failure caught / wrapped / swallowed so it hides the root cause; silent fallbacks (`except: return []`).
- **Context loss** — diff contradicts earlier decisions, the plan, or the project's standards.
- **Tool misuse** — wrong tool for the job, or the right tool with wrong params.

Any mode flagged → fix and re-run; do not claim done.
