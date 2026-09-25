## Receiving Code Review

Read it all → restate each item → verify against the code → respond → implement one item at a time, testing each. Anything unclear → ask about **all** unclear items before implementing any.

| Source | Handling |
|---|---|
| **User** | Trusted — implement once understood. |
| **Workflow reviews** (`/review-diff`, `spec-review`, Codex `changes-review` / companion) | `must_fix` / `should_fix` → fix; `suggestion` → if quick. No discussion. The invoking workflow's lane rules win (`spec-verify` fixes via a loop-back commit). |
| **External** (CodeRabbit, PR reviewers) | Verify first: correct for *this* codebase? breaks something? a reason for the current code? conflicts with the user's decisions → discuss with the user first. |

- **YAGNI:** a suggestion to add or "properly implement" something → search for real callers; none → push back ("unused — remove it?").
- **Order:** clarify → blocking (breaks, security) → simple → complex.
- **Push back** with technical reasons when a suggestion is wrong, breaks things, lacks context, or conflicts with the user's decisions; if you were wrong, correct it factually and move on.
- No performative agreement ("You're absolutely right!", "Great catch!") — state the fix: "Fixed. <what changed>".
