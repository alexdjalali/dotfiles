# TypeScript / React (Vite) Standards

Grounded in the flagship frontend **bloodhound-search-platform** (`apps/frontend/web`): Vite + React 19 + react-router + Tailwind v4 + Auth0. This is a Vite SPA, **not** Next.js.

## Tooling
- Package manager: `pnpm` (never npm/yarn)
- Build/dev: **Vite**
- Lint: ESLint (`eslint-plugin-react`, `eslint-plugin-react-hooks`, `eslint-plugin-react-refresh`) + Prettier
- Type check: `tsc --noEmit` (strict)
- Test: `vitest` + `@vitest/coverage-v8`; React Testing Library (`@testing-library/react`, `jest-dom`)
- No `any` (use `unknown` + type guards). No `console.log` in committed code. Prefer `const`; never `var`.

## React Conventions
- React 19, functional components only
- **React Compiler** (`babel-plugin-react-compiler`) handles memoization — do **not** scatter `useMemo`/`useCallback` by default; add manual memoization only where the compiler can't help and profiling shows a need
- Custom hooks for shared logic (`use` prefix); keep hooks composable and focused
- Props: destructure in function signature; use `interface` for prop types (not `type`)
- State: `useReducer` for complex state; `useState` for simple values
- Effects: always specify dependency arrays; clean up subscriptions/listeners
- Routing: **react-router** (data routers / loaders); one exported component per file, colocate styles and tests
- Auth: `@auth0/auth0-react` (`useAuth0`, protected routes) — never hand-roll token handling
- Error boundaries for failure isolation at route/feature level

## Tailwind CSS (v4)
- Tailwind **v4** via `@tailwindcss/vite`; theme is configured **CSS-first** (`@theme` in the stylesheet), not a `tailwind.config.ts`
- Use utility classes directly; extract repeated patterns into React components, not `@apply`
- Merge conditional classes with `tailwind-merge`
- Responsive: mobile-first (`sm:`, `md:`, `lg:`); dark mode via `dark:` consistently
- No inline `style={}` when Tailwind utilities exist

## Testing Requirements
- `describe`/`it` blocks with descriptive names (reads as a specification)
- Every test has a comment: **Why important** + **What it tests**
- React Testing Library — test behavior, not implementation
- **Test doubles: mocks and fixtures, not fakes.** Mock the network boundary (MSW or `vi.mock`) and reuse shared test utilities; do not hand-roll a fake reimplementation of a client/service when a mock or fixture will serve
- Test file pattern: `<file>.test.ts(x)` colocated with source; shared utilities in `tests/helpers/`

## Documentation Requirements
- JSDoc/TSDoc on public functions, types, exported modules (`@param`, `@returns`, `@example`)
- Inline comments for non-obvious logic only; no comments that restate the code
- A code change updates every comment / README / doc that references it, **directly or indirectly** (a caller or documented behavior that depends on it)

## Flagship Reference

Org engineering standards (Go/Python-focused, but the distributed-systems techniques inform frontend resilience & UX — e.g. read-your-writes affordances for ingestion lag):
- [The Top 50 Techniques for Distributed Engineering](https://alexdjalali.github.io/posts/top-50-techniques-for-distributed-engineering/)
- [100 Patterns for Production Go and Python](https://alexdjalali.github.io/posts/100-patterns-for-production-go-and-python/)

## Quality Gates
1. `prettier --check` — code formatting
2. `eslint` — linting
3. `tsc --noEmit` — type checking (strict mode)
4. `vitest run` — all tests pass
5. `vitest run --coverage` — coverage report
