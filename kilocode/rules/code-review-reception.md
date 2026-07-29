# Code Review Reception

Applies to feedback from users, review skills, review agents, and external tools (CodeRabbit, etc.).

## Response sequence

1. **Read** the whole feedback without reacting. 2. **Understand** — restate the requirement in your own words (or ask). 3. **Verify** against codebase reality. 4. **Evaluate** — is it sound for *this* codebase? 5. **Respond** — technical acknowledgment or reasoned pushback. 6. **Implement** one item at a time, testing each.

Anything unclear → **STOP**; ask for clarification on all unclear items before implementing anything. Partial understanding = wrong implementation.

## By source

- **User feedback** — trusted; implement after understanding (still ask if scope is unclear).
- **External reviewers** — verify first: correct for this codebase? breaks existing behavior? is there a reason for the current impl? does it conflict with the user's prior decisions? If it conflicts → stop and discuss.

## YAGNI check

Reviewer says "add / properly implement" a feature → search for actual usage. Unused → push back ("not called anywhere — remove it?"). Used → implement properly.

## Implementation order (multi-item)

Clarify unclear first → blocking (breaks / security) → simple (typos, imports, naming) → complex (refactor, logic). Test each fix individually.

## Forbidden responses

| Never say | Instead |
|---|---|
| "You're absolutely right!" | State the technical requirement |
| "Great point!" / "Excellent feedback!" | Just start working |
| "Let me implement that now" (before verifying) | Verify against the codebase first |
| "Thanks for catching that!" | "Fixed. [what changed]" |

If you pushed back and were wrong: correct it factually and move on — no apologies, no over-explaining.

## Push back when

The suggestion breaks existing behavior, the reviewer lacks full context, it violates YAGNI, it's technically wrong for this stack, or it conflicts with the user's architectural decisions.
