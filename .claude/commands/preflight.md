---
model: sonnet
---

# Preflight — Pre-Commit Quality Gate

Run all quality checks on changed files before committing.

## Arguments
$ARGUMENTS — Optional: specific files to check. If empty, checks all uncommitted/staged changes.

## Instructions

### 1. Identify Changed Files

```bash
git diff --name-only
git diff --cached --name-only
```

Group files by language: Python (.py), Go (.go), TypeScript/JavaScript (.ts/.tsx/.js/.jsx), other.

If `$ARGUMENTS` specifies files, use those instead.

### 2. Run Quality Gates (in order)

#### Gate 1: Format

| Language | Command | Auto-fix |
|----------|---------|----------|
| Python | `ruff format <files>` | Yes (in-place) |
| Go | `gofumpt -w <files>` | Yes (in-place) |
| TS/JS | `prettier --write <files>` | Yes (in-place) |

Report any files that were reformatted.

#### Gate 2: Lint

| Language | Command | Auto-fix |
|----------|---------|----------|
| Python | `ruff check --fix <files>` | Partial |
| Go | `golangci-lint run <packages>` | No |
| TS/JS | `npx eslint --fix <files>` | Partial |

Report remaining lint errors after auto-fix.

#### Gate 3: Type Check

| Language | Command |
|----------|---------|
| Python | `basedpyright <files>` or `mypy --strict <files>` |
| Go | `go vet ./...` |
| TS/JS | `npx tsc --noEmit` |

Report type errors.

#### Gate 4: Tests

Run tests related to the changed modules:

| Language | Command |
|----------|---------|
| Python | `pytest <test_files> -x --tb=short` |
| Go | `go test <packages> -count=1` |
| TS/JS | `npx vitest run --reporter=verbose <test_files>` |

Identify related test files by convention:
- Python: `test_<module>.py` or `<module>_test.py` in `tests/` directory
- Go: `<file>_test.go` in same package
- TS/JS: `<file>.test.ts` or `<file>.spec.ts`

### 3. Generate Report

```
## Preflight Report

### Files Checked
- <list of files by language>

### Results

| Gate | Status | Details |
|------|--------|---------|
| Format | PASS/FIXED | N files reformatted |
| Lint | PASS/FAIL | N issues (M auto-fixed) |
| Type Check | PASS/FAIL | N errors |
| Tests | PASS/FAIL | N passed, M failed |

### Overall: READY / NOT READY

### Issues Requiring Manual Fix
- ...
```

### 4. Suggest Commit Message

If all gates pass (READY), suggest a conventional commit message based on the changes:

```
<type>: <description>
```

Where type is one of: feat, fix, refactor, docs, test, chore, perf, ci

### 5. Gate Decision

**If NOT READY, present an explicit gate before proceeding.**

```
AskUserQuestion:
  question: "Preflight found issues. How should we proceed?"
  header: "Preflight Gate"
  options:
    - "Auto-fix and re-run" (Recommended) — Fix all auto-fixable issues, then re-run gates
    - "Fix and commit anyway" — Fix what's possible, commit with remaining warnings
    - "Abort" — Do not commit; user will fix manually
```

**Based on response:**
- **Auto-fix and re-run:** Apply all auto-fixes, re-run all 4 gates. If still NOT READY, report remaining issues.
- **Fix and commit anyway:** Apply fixes, commit with a note about known issues (only if remaining issues are warnings, not errors).
- **Abort:** Report the full issue list and stop. Do not modify files or commit.

### 6. If READY

All gates passed. Suggest commit message and offer to proceed:

```
AskUserQuestion:
  question: "All gates pass. Commit with this message?"
  header: "Commit"
  options:
    - "Yes, commit" (Recommended) — Commit with the suggested message
    - "Edit message" — Let me provide a different commit message
    - "Skip commit" — Gates passed but don't commit yet
```
