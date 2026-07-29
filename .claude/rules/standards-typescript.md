---
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.js"
  - "**/*.jsx"
  - "**/*.mjs"
  - "**/*.mts"
---

## TypeScript Development Standards

**Standards:** Detect package manager (prefer pnpm greenfield) | Strict types | No `any` | Self-documenting code

### Package Manager - DETECT FIRST

**Detect and use the project's existing package manager. Never mix.**

- `bun.lockb` → **bun** | `pnpm-lock.yaml` → **pnpm** | `yarn.lock` → **yarn** | `package-lock.json` → **npm**

No lock file? Check `packageManager` in `package.json`, or default to **pnpm** (preferred for greenfield).

### Type Safety

- **Explicit return types** on all exported functions
- **Interfaces** for objects, **types** for unions
- **Never use `any`** — use `unknown`, a specific type, or a generic instead

### Code Style

- Self-documenting code, minimize comments
- One-line JSDoc for exports: `/** Calculate discounted price. */`
- **Import order:** Node built-ins (`node:`) → External → Internal → Relative
- **File names:** kebab-case (`user-service.ts`)

### Common Patterns

- Prefer `node:` prefix for built-ins: `import { readFile } from 'node:fs/promises'`
- Use `const` assertions for literal types: `const ROLES = ['admin', 'user'] as const`
- Don't swallow errors — log and re-throw

### Testing - Minimal Output

`vitest` is the modern default (`vitest run`, `vitest run --coverage`); the flags below also work with any Jest-compatible runner. (React/component specifics live in `standards-frontend.md`.)

```bash
npm test -- --silent         # Suppress console.log
npm test -- --reporters=dot  # Minimal reporter
npm test -- --bail           # Stop on first failure
```

### Integration tests (testcontainers)

Node/TS integration tests that need a backing service run it in a **real Docker container** via `@testcontainers/postgresql` (or core `testcontainers` `GenericContainer` for services without a module) — never a mock or in-memory substitute. Keep them in a separate suite (e.g. `*.integration.test.ts` / a dedicated vitest project) so the unit run stays fast. Unit tests mock the boundary (`vi.mock` / `vi.fn`); a hand-rolled fake standing in for a real service is a `must_fix`.

```bash
pnpm add -D @testcontainers/postgresql   # or: testcontainers (GenericContainer)
```

```ts
import { PostgreSqlContainer } from "@testcontainers/postgresql";

// Why: real SQL/driver behavior is invisible to a mock. What: rows persist and read back.
const pg = await new PostgreSqlContainer("postgres:16").start();
const uri = pg.getConnectionUri();
// … connect with `uri`, run assertions against the live DB …
await pg.stop();
```

A *frontend's* "integration" is usually Playwright browser E2E (`standards-frontend.md`) — that containerizes nothing, which is expected.

### Verification Checklist

Check `package.json` scripts first — projects often have custom configurations.

- [ ] `tsc --noEmit` — no type errors
- [ ] Lint clean (eslint flat config / biome)
- [ ] Tests pass
- [ ] Explicit return types on exports
- [ ] No `any` types
- [ ] Correct lock file committed
- [ ] Production files ideally under 800 lines (1000+ = consider splitting)

### Quick Reference

| Task | pnpm | bun | npm | yarn |
|------|------|-----|-----|------|
| Install | `pnpm install` | `bun install` | `npm install` | `yarn` |
| Add pkg | `pnpm add pkg` | `bun add pkg` | `npm install pkg` | `yarn add pkg` |
| Run script | `pnpm x` | `bun x` | `npm run x` | `yarn x` |
