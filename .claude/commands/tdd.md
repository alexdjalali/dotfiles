---
description: Implement a behavior using strict red-green-refactor TDD
---

Implement the described behavior one test at a time.

## Red -- Write a Failing Test

1. Write exactly one test for the next behavior to add.
2. Test observable behavior, not implementation details.
3. Naming:
   - Python: `test_<function>_<scenario>_<expected>`
   - TypeScript: `it("should <behavior> when <condition>")`
   - Go: `TestFunctionName_Scenario`
4. Mock all external dependencies: HTTP, DB, filesystem, subprocess, time.
5. Run the test. Confirm it **fails for the right reason** -- the feature does not exist yet, not a syntax error.

If the test passes immediately, the test is wrong. Rewrite it before continuing.

## Green -- Make It Pass

Write the simplest code that makes the test pass. No extras. Hardcoding is fine at this stage.

Run the full test suite. All existing tests must stay green.

## Refactor -- Improve Without Changing Behavior

Remove duplication, improve naming, clarify structure. Tests must stay green throughout the refactor.

Then loop: identify the next behavior and return to Red.

## Done

All specified behaviors are implemented and tested. Run `/preflight` before committing.

## Rules

- NEVER write implementation before a failing test
- NEVER write more test than needed to make the current step fail
- NEVER skip the refactor step -- "it looks fine" is not a reason
- NEVER mock internal collaborators -- only external boundaries (network, disk, time, DB)
- A test passing on first run means the test is probably wrong -- investigate
