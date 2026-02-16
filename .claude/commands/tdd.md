# TDD Cycle

Focused red-green-refactor cycle for a single feature or function.

## Arguments
$ARGUMENTS — Description of the feature, function, or behavior to implement via TDD.

## Instructions

### 1. Detect Language & Test Framework

Check project configuration to determine:
- **Python**: Look for `pyproject.toml` (pytest config), `uv.lock` → use `pytest`
- **Go**: Look for `go.mod` → use `go test` with table-driven tests
- **TypeScript**: Look for `package.json` (vitest/jest config) → use `vitest`

### 2. RED — Write Failing Test First

Based on `$ARGUMENTS`, write a test that:
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

### 3. GREEN — Minimal Implementation

Write the **simplest code** that makes the test pass:
- No optimization
- No generalization
- No extra features
- Just make the test green

Run the test — confirm it **PASSES**.

### 4. REFACTOR — Improve Without Changing Behavior

Now clean up:
- Extract duplicated logic
- Improve naming
- Simplify conditionals
- Add type annotations if missing

Run the test again — confirm it still **PASSES**.

### 5. Expand (if needed)

If `$ARGUMENTS` implies additional cases:
- Add another failing test (back to RED)
- Repeat the cycle

### 6. Quality Gate

After all cycles are complete, run the full quality suite on the changed files:
- Format check
- Lint
- Type check
- All tests in the module

Report results and any remaining issues.

## Rules
- NEVER write implementation before a failing test
- NEVER write more test than needed for the current step
- NEVER skip the refactor step (even if the code "looks fine")
- If a test passes on first run, the test is probably wrong — investigate
