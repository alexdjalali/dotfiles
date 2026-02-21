---
model: sonnet
---

# TDD Cycle

Focused red-green-refactor cycle for a single feature or function. Used standalone or delegated to by `spec-implement` for each plan task.

## Arguments
$ARGUMENTS — One of:
- Feature/behavior description (standalone mode)
- `--task <N> --plan <path>` (pipeline mode, invoked by spec-implement)

## Instructions

### 0. Determine Mode

```
IF $ARGUMENTS contains "--task" AND "--plan":
    → Pipeline mode: extract task context from plan, skip quality gate
    Parse: task number and plan path

ELSE:
    → Standalone mode: full cycle with quality gate and checklist
```

**Pipeline mode context gathering:**
1. Read the plan file at `<path>`
2. Find the task section matching `Task <N>`
3. Extract: objective, files (create/modify/test), key decisions, DoD criteria
4. Use these to guide what tests to write and what code to implement

---

### 1. Detect Language & Test Framework

Check project configuration to determine:
- **Python**: Look for `pyproject.toml` (pytest config), `uv.lock` → use `pytest`
- **Go**: Look for `go.mod` → use `go test` with table-driven tests
- **TypeScript**: Look for `package.json` (vitest/jest config) → use `vitest`

### 2. Call Chain Analysis (pipeline mode) / Scope Analysis (standalone)

Before writing any code, understand the impact:

1. **Trace Upwards (Callers):** Identify what calls the code you're modifying
2. **Trace Downwards (Callees):** Identify what the modified code calls
3. **Side Effects:** Check for database, cache, external system impacts

In standalone mode, read the relevant source files to understand the interface boundaries.

### 3. RED — Write Failing Test First

Based on task context (pipeline) or `$ARGUMENTS` (standalone), write a test that:
- Tests the **behavior**, not the implementation
- Has a descriptive name that reads as a specification
- Covers the primary success case
- Includes at least one edge case

**Python pattern**:
```python
def test_<behavior>_<scenario>():
    # Arrange
    ...
    # Act
    result = function_under_test(...)
    # Assert
    assert result == expected
```

**Go pattern**:
```go
func TestFunctionName(t *testing.T) {
    tests := []struct {
        name string
        input ...
        want  ...
    }{
        {"success case", ..., ...},
        {"edge case", ..., ...},
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got := FunctionUnderTest(tt.input)
            if got != tt.want {
                t.Errorf("got %v, want %v", got, tt.want)
            }
        })
    }
}
```

**TypeScript pattern**:
```typescript
describe('functionName', () => {
  it('should <behavior> when <scenario>', () => {
    // Arrange
    ...
    // Act
    const result = functionUnderTest(...)
    // Assert
    expect(result).toBe(expected)
  })
})
```

Run the test — confirm it **FAILS** with a clear error (not a syntax/import error).

### 4. GREEN — Minimal Implementation

Write the **simplest code** that makes the test pass:
- No optimization
- No generalization
- No extra features
- Just make the test green

Run the test — confirm it **PASSES**.

### 5. REFACTOR — Improve Without Changing Behavior

Now clean up:
- Extract duplicated logic
- Improve naming
- Simplify conditionals
- Add type annotations if missing

Run the test again — confirm it still **PASSES**.

### 6. Property-Based Testing (when applicable)

If the function has well-defined input/output invariants, add property-based tests:

**Python (hypothesis)**:
```python
from hypothesis import given, strategies as st

@given(st.lists(st.integers()))
def test_sort_preserves_length(xs):
    assert len(sorted(xs)) == len(xs)

@given(st.lists(st.integers()))
def test_sort_is_idempotent(xs):
    assert sorted(sorted(xs)) == sorted(xs)
```

**Go (rapid)**:
```go
func TestSortPreservesLength(t *testing.T) {
    rapid.Check(t, func(t *rapid.T) {
        xs := rapid.SliceOf(rapid.Int()).Draw(t, "xs")
        got := Sort(xs)
        if len(got) != len(xs) {
            t.Fatalf("length changed: %d → %d", len(xs), len(got))
        }
    })
}
```

Good candidates for property-based tests:
- Pure functions with clear invariants (idempotency, commutativity, roundtrips)
- Serialization/deserialization roundtrips
- Parser/formatter pairs
- Mathematical properties (associativity, identity elements)

### 7. Expand (if needed)

If the task (pipeline) or `$ARGUMENTS` (standalone) implies additional cases:
- Add another failing test (back to RED)
- Repeat the cycle

### 8. Verify Tests Pass

Run the project's test runner on all tests for the affected module:
- `uv run pytest <test_files> -q`
- `go test <packages> -count=1`
- `npx vitest run <test_files>`

**In pipeline mode:** Also check diagnostics (lint, type check) — must be zero errors.

---

### 9. Quality Gate (standalone mode only)

**⚠️ Skip this step in pipeline mode.** When called from spec-implement, quality gates are handled by spec-verify.

After all cycles are complete, run the full quality suite on the changed files:
- Format check
- Lint
- Type check
- All tests in the module

Report results and any remaining issues.

### 10. Completion Checklist (standalone mode only)

**⚠️ Skip this step in pipeline mode.** When called from spec-implement, the plan's DoD criteria and spec-verify handle completion tracking.

#### Coding Patterns (verify where appropriate)

- [ ] **Fluent Interface** — method chaining for readable configuration/setup
- [ ] **Builder Pattern** — complex object construction
- [ ] **DRY** — no duplicated logic; extract shared utilities
- [ ] **Decorator Pattern** — wrap behavior (retry, circuit breaker, logging)
- [ ] **Strategy Pattern** — interchangeable algorithms (e.g., error classifiers)
- [ ] **Observer Pattern** — event-driven notifications (e.g., metrics, logging hooks)
- [ ] **Singleton Pattern** — single instance resources (e.g., DB connections, model instances)
- [ ] **Facade Pattern** — simplified interface over complex subsystems

#### Testing Requirements

- [ ] >90% unit test coverage
- [ ] Organized test structure with descriptive names
- [ ] Every test documents: **Why important** + **What it tests**
- [ ] Shared test fixtures and helpers (see language standards)
- [ ] Edge cases covered and documented

#### Documentation Requirements

- [ ] Module/package-level documentation on new files
- [ ] Public API documentation on new/changed classes, methods, and functions
- [ ] Inline comments for non-obvious logic only
- [ ] Type annotations on all public APIs

### 11. Pipeline: Next Step (standalone mode only)

**⚠️ Skip this step in pipeline mode.** Control returns to spec-implement automatically.

After the TDD cycle completes, suggest the next step:

Use AskUserQuestion:

```
question: "TDD cycle complete. What's next?"
header: "Pipeline"
options:
  - "/preflight — Run quality gates" - Format, lint, type check, and test before committing
  - "/review — Code review" - Review the changes before committing
  - "Done — Commit manually" - No further automated steps
```

Based on the user's choice, invoke the corresponding skill:
- `/preflight`: `Skill(skill='preflight')`
- `/review`: `Skill(skill='review')`
- Done: End the workflow

## Rules
- NEVER write implementation before a failing test
- NEVER write more test than needed for the current step
- NEVER skip the refactor step (even if the code "looks fine")
- If a test passes on first run, the test is probably wrong — investigate
