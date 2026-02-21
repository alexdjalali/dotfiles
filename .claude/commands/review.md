# Code Review

Analyze uncommitted and staged changes with language-aware checks, automated tooling, and a structured report.

## Arguments
$ARGUMENTS — Optional: specific files or directories to focus on. If empty, review all uncommitted changes.

## Instructions

### 1. Gather Changes

```bash
git diff --stat
git diff --cached --stat
git status --short
```

If `$ARGUMENTS` specifies files, scope the review to those files only.

### 2. Run Automated Checks

Detect project languages and run the appropriate tools on changed files:

**Python (.py)**:
- `ruff check <files>` (linting)
- `ruff format --check <files>` (formatting)
- `basedpyright <files>` or `mypy --strict <files>` (type checking)

**Go (.go)**:
- `golangci-lint run <packages>` (linting)
- `gofumpt -l <files>` (formatting)
- `go vet <packages>` (static analysis)

**TypeScript/JavaScript (.ts/.tsx/.js/.jsx)**:
- `npx eslint <files>` (linting)
- `npx prettier --check <files>` (formatting)
- `npx tsc --noEmit` (type checking)

### 3. Manual Code Review

Read the actual diffs (`git diff` and `git diff --cached`) and check for:

**All Languages**:
- [ ] Hardcoded secrets, URLs, or config values
- [ ] Files >800 lines, functions >50 lines
- [ ] Nesting >4 levels deep
- [ ] Missing error handling
- [ ] Import cycles or circular dependencies
- [ ] Tests cover the changed behavior

**DRY & Pattern Analysis**:
- [ ] Duplicated logic — similar code blocks across changed files (extract to shared function)
- [ ] Pattern consistency — does new code follow existing project patterns?
- [ ] Missed abstractions — 3+ similar lines that could be a function or type
- [ ] Copy-paste drift — near-identical code with subtle variations (source of bugs)
- [ ] Reuse opportunities — does the codebase already have a util/helper for this?

**Functional Style & Mutation Checks**:
- [ ] Unnecessary mutation — prefer immutable data, transform over mutate
- [ ] Side effects in pure logic — separate I/O from computation
- [ ] Deep nesting → use early returns, guard clauses, or `map`/`filter`/`reduce`
- [ ] Mutable shared state across goroutines/async tasks

**Python-Specific**:
- [ ] `print()` instead of structured logging
- [ ] Bare `except:` clauses
- [ ] Missing type annotations on public functions
- [ ] Relative imports across packages
- [ ] Mutable default arguments (`def f(x=[])`)

**Go-Specific**:
- [ ] Unchecked errors
- [ ] `fmt.Println` in production code
- [ ] Missing `defer` for cleanup
- [ ] `interface{}` without type assertion
- [ ] Exported functions missing doc comments

**TypeScript-Specific**:
- [ ] `any` type usage
- [ ] `console.log` in committed code
- [ ] `var` declarations
- [ ] Missing dependency arrays in `useEffect`

### 4. Generate Report

Output a structured review:

```
## Code Review Report

### Summary
<1-2 sentence overview of changes>

### Automated Tool Results
- Linting: PASS/FAIL (N issues)
- Formatting: PASS/FAIL
- Type Check: PASS/FAIL (N errors)

### Manual Review Findings

#### Critical (must fix)
- ...

#### Warning (should fix)
- ...

#### Suggestion (nice to have)
- ...

### Verdict
APPROVE / REQUEST CHANGES / NEEDS DISCUSSION
```

### 5. Suggest Fixes

For any Critical or Warning findings, offer to fix them automatically where possible.
