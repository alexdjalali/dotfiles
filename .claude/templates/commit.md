# Conventional Commit Template

## Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

## Types

| Type | When to use |
|------|------------|
| `feat` | New feature or capability |
| `fix` | Bug fix |
| `refactor` | Code change that neither fixes a bug nor adds a feature |
| `test` | Adding or updating tests |
| `docs` | Documentation only |
| `chore` | Build, CI, tooling, dependencies |
| `perf` | Performance improvement |
| `ci` | CI/CD pipeline changes |
| `style` | Formatting, whitespace (no logic change) |

## Rules

- **Subject**: imperative mood, lowercase, no period, max 72 chars
- **Scope**: optional, identifies the module/area (e.g., `auth`, `api`, `db`)
- **Body**: explain WHY, not WHAT (the diff shows what). Wrap at 72 chars.
- **Footer**: `Closes #N`, `Refs #N`, `BREAKING CHANGE: <description>`
- **No scope for cross-cutting changes** that touch many areas

## Examples

```
feat(auth): add JWT refresh token rotation

Tokens were only valid for 15 minutes with no refresh mechanism,
forcing users to re-authenticate frequently.

Closes #42
```

```
fix(api): prevent race condition in concurrent order updates

Two simultaneous updates to the same order could corrupt the total.
Added optimistic locking via version field.

Refs #118
```

```
refactor: consolidate spec pipeline output directories

Merged docs/plans/, docs/architecture/, docs/rfp/ into unified
docs/spec/ structure with subdirectories for arch, epics, stories,
and plans.

BREAKING CHANGE: existing docs/plans/ paths must be updated to
docs/spec/plans/
```
