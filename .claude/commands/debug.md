---
model: opus
---

# Structured Debugging

Scientific method for diagnosing and fixing bugs. No random code changes.

## Arguments
$ARGUMENTS — Description of the bug, error message, or unexpected behavior.

## Instructions

### Phase 1: REPRODUCE

**Goal**: Create a reliable, minimal reproduction of the bug.

1. **Understand the report**: Parse `$ARGUMENTS` for error messages, stack traces, expected vs actual behavior.

2. **Write a failing test** that demonstrates the bug:
   - The test should pass when the bug is fixed
   - It should fail with the same error/behavior described in the report
   - Keep it minimal — isolate the specific behavior

3. **Confirm reproduction**: Run the test and verify it fails consistently.

If the bug cannot be reproduced with a test, document why and proceed with manual investigation.

### Phase 2: ISOLATE

**Goal**: Narrow down the root cause location.

Use these techniques as appropriate:

- **Read the stack trace**: Follow the call chain from the error to its origin
- **Binary search / bisect**: If the bug is in a sequence of operations, find which step causes it
- **Trace data flow**: Follow the data from input to the point of failure
- **Check recent changes**: `git log --oneline -20` and `git diff HEAD~5` for recent modifications
- **Inspect state**: Add targeted logging or use debugger to examine variable state at key points
- **Check boundaries**: Look at the interfaces between components where the bug manifests

### Phase 3: DIAGNOSE

**Goal**: State the root cause clearly.

Write a diagnosis that includes:
1. **What** is happening (the symptom)
2. **Where** in the code it occurs (file, function, line)
3. **Why** it happens (the root cause, not the symptom)
4. **When** it was introduced (if identifiable from git history)

Format:
```
## Diagnosis

**Symptom**: <what the user sees>
**Location**: <file:line>
**Root Cause**: <why it happens>
**Introduced**: <commit/PR if identifiable>
```

### Phase 4: FIX (via /tdd)

**Goal**: Fix the bug with confidence using the TDD cycle.

The failing test from Phase 1 serves as the RED step. Delegate the fix to `/tdd`:

```
Skill(skill='tdd', args='Fix: <root cause summary from Phase 3>')
```

The `/tdd` skill will:
1. Verify the failing test still fails (RED — already done in Phase 1)
2. Apply the minimal fix (GREEN)
3. Refactor if needed (keep tests green)
4. Run the full test suite for regressions

### Phase 5: VERIFY

**Goal**: Ensure the fix is complete and hasn't introduced new issues.

1. Run the full quality suite on changed files:
   - Format, lint, type check, tests
2. Check for similar patterns elsewhere:
   - If the bug was caused by a common mistake, search for the same pattern in the codebase
3. Document the fix:
   - What was the root cause?
   - What was changed?
   - Are there related areas that should be reviewed?

### Report

```
## Debug Report

### Bug
<original description>

### Diagnosis
- **Root Cause**: <explanation>
- **Location**: <file:line>

### Fix
- **Changes**: <list of files modified>
- **Test**: <test file and test name that covers this>

### Verification
- [ ] Failing test now passes
- [ ] No regressions in module tests
- [ ] Quality gates pass (format, lint, type check)
- [ ] Similar patterns checked elsewhere

### Prevention
<suggestions to prevent similar bugs>
```

## Rules
- NEVER change code before understanding the root cause
- NEVER fix a bug without a test that reproduces it
- NEVER apply a fix that you can't explain
- If the fix is complex, consider whether the underlying design needs an ADR
