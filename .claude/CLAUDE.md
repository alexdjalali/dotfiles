# Global Engineering Standards

## Process

All structural changes follow: ADR → Design → TDD → Implement → Verify.

- **ADR first**: Before architectural changes, write an ADR in `docs/adr/`. No structural code without rationale.
- **Plan before code**: Use `/spec` for non-trivial work. Explore and design precede implementation.
- **TDD mandatory**: Write failing tests FIRST. Red → Green → Refactor.
- **Verify before done**: Run linters, type checkers, and tests before marking work complete.

## Language Standards

### Python (3.14+)
- Package manager: `uv` (never pip/poetry)
- Lint + format: `ruff check` + `ruff format`
- Type check: `basedpyright` (strict) or `mypy --strict`
- Test: `pytest` with markers per layer (unit, integration, e2e)
- Models: `@attrs.define(frozen=True, slots=True)` or frozen dataclasses
- Async: `async def` + `await`; `asyncio.run()` only at boundaries
- Imports: absolute only; no cross-package relative imports
- Docstrings: Google style. Line length: 100.
- No `print()` in production; use structured logging
- No bare `except:`

### Go (1.26+)
- Format: `gofumpt` + `goimports`
- Lint: `golangci-lint`
- Test: table-driven with `t.Run()` subtests; `t.Parallel()` where safe
- Errors: always check; wrap with `fmt.Errorf("context: %w", err)`
- Interfaces: small (1-3 methods), consumer-defined; accept interfaces, return structs
- No `fmt.Println` in production; use structured logger. Line length: 140.
- Naming: MixedCaps (exported), mixedCaps (unexported); acronyms all-caps (HTTPClient, ID)
- Concurrency: prefer channels over shared memory; always `defer` cleanup
- Context: pass `ctx context.Context` as first parameter

### TypeScript / React / Next.js
- Package manager: `pnpm` (never npm/yarn)
- Lint: ESLint + Prettier. Type check: `tsc --noEmit` (strict)
- Test: `vitest` for unit/integration; React Testing Library for component tests
- No `any` type (use `unknown` + type guards). No `console.log` in committed code.
- Prefer `const`; never `var`.

### React Conventions
- Functional components only (no class components)
- Custom hooks for shared logic (`use` prefix); keep hooks composable and focused
- Props: destructure in function signature; use `interface` for prop types (not `type`)
- State: prefer `useReducer` for complex state; `useState` for simple values
- Effects: always specify dependency arrays; clean up subscriptions/listeners
- Memoization: `useMemo`/`useCallback` only when profiling shows a need, not by default
- Component files: one exported component per file; colocate styles and tests
- Error boundaries for failure isolation at route/feature level

### Tailwind CSS
- Use utility classes directly; avoid `@apply` except in base/component layers
- Extract repeated patterns into React components, not CSS classes
- Responsive: mobile-first (`sm:`, `md:`, `lg:` breakpoints)
- Dark mode: use `dark:` variant consistently
- Custom values: extend theme in `tailwind.config.ts` rather than arbitrary values `[...]`
- Class ordering: follow Tailwind Prettier plugin ordering (install `prettier-plugin-tailwindcss`)
- No inline `style={}` when Tailwind utilities exist

## Quality Gates (before every commit)
1. Format (ruff format / gofumpt / prettier + tailwindcss plugin)
2. Lint (ruff check / golangci-lint / eslint)
3. Type check (basedpyright / go vet / tsc --noEmit)
4. Unit tests for changed modules

## Git Conventions
- Conventional commits: `<type>: <description>` (feat, fix, refactor, docs, test, chore, perf, ci)
- Branch naming: `<type>/<short-description>`
- Never force-push to main/master

## Architecture Patterns
- Clean/layered: Foundation → Client → Service/Domain → Controller/API
- Dependency injection at composition root
- Repository pattern for data access
- Event-driven messaging between services
- Early returns over nested conditionals
- Separate persistence models, domain entities, and DTOs

## Anti-Patterns to Avoid
- Files >800 lines, functions >50 lines, nesting >4 levels
- Hardcoded secrets/URLs/config values
- Mutable shared state across goroutines/async tasks
- `any`/`interface{}` without type narrowing
- Import cycles
- Testing implementation details instead of behavior
