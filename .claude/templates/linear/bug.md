# <Symptom, plainly — e.g. "Workspaces don't appear for admins in staging">

> Linear **bug** template. Lead with what a user sees. For a UI bug attach a **screenshot**; for a
> cross-service bug a **sequence** marking where the flow breaks; for a lifecycle bug a **state**
> diagram of the stuck/illegal transition (diagram guide: `~/.claude/rules/linear.md`). Priority
> reflects severity (Linear field). A fix isn't done without a test that fails before it and passes after.

## Background

<Where this shows up and who it affects. The single most useful sentence is usually the
condition where it happens vs. doesn't — "works locally, 403s in staging".>

## Steps to Reproduce

1. <step>
2. <step>

**Expected:** <what should happen>
**Actual:** <what happens instead>

## Root Cause

<Fill in once known — the mechanism + `file:line`, or a link to the RCA. Leave as
"not yet pinned" with the next diagnostic step if it's still open.>

## Acceptance Criteria

- [ ] A reproducing test fails before the fix and passes after (revert-proof)
- [ ] The root cause is fixed, not just the symptom; parallel occurrences checked
- [ ] <observable behaviour that must now hold>

## References

<RCA doc · related issues · PR>
