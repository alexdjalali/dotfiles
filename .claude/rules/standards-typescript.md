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
