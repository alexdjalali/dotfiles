# TypeScript / React / Next.js Standards

## Tooling

- Package manager: detect the project's lockfile (pnpm/bun/yarn/npm) and use it; prefer `pnpm` for greenfield. Never mix.
- Lint: ESLint + Prettier. Type check: `tsc --noEmit` (strict)
- Test: `vitest` for unit/integration; React Testing Library for component tests
- No `any` type (use `unknown` + type guards). No `console.log` in committed code.
- Prefer `const`; never `var`.

## React Conventions

- Functional components only (no class components)
- Custom hooks for shared logic (`use` prefix); keep hooks composable and focused
- Props: destructure in function signature; use `interface` for prop types (not `type`)
- State: prefer `useReducer` for complex state; `useState` for simple values
- Effects: always specify dependency arrays; clean up subscriptions/listeners
- React 19 + **React Compiler** handles memoization — don't scatter `useMemo`/`useCallback`; add manually only where profiling shows the compiler can't help
- Component files: one `export default function` per PascalCase file; colocated `*.test.tsx`; one-line `/** Name — … */` doc
- Feature-first layout: `components/ui` primitives, `components/shared` composites, `features/<domain>` behind a barrel `index.ts`, `layout/` shell; import via `@/*`, no deep `../../`
- Data via the query layer (e.g. TanStack Query) — no raw `fetch` in components; mutations invalidate their keys; API clients/types generated from the backend contract, never hand-edited
- User-visible strings through `t()` (i18n)
- Error boundaries for failure isolation at route/feature level

## Tailwind CSS

- Use utility classes directly; avoid `@apply` except in base/component layers
- Extract repeated patterns into React components, not CSS classes
- Responsive: mobile-first (`sm:`, `md:`, `lg:` breakpoints)
- Dark mode: use `dark:` variant consistently
- Tailwind v4: configure the theme **CSS-first** via `@theme` in the stylesheet (not `tailwind.config.ts`); merge conditional classes with `tailwind-merge`. Avoid arbitrary values `[...]` where a token exists.
- Class ordering: follow Tailwind Prettier plugin ordering
- No inline `style={}` when Tailwind utilities exist

## Accessibility & Performance

- **A11y:** semantic HTML; label every control; keyboard-navigable; visible focus states; sufficient color contrast; `alt` text on images; ARIA only when native semantics can't express it.
- **Performance:** hot paths (lists, effects, request handlers) avoid redundant recompute; lazy-load heavy routes/components; virtualize long lists; memoize only where profiling shows the React Compiler can't; keep bundles lean.
- **Design direction:** consistent spacing / type scale / design tokens; responsive mobile-first; dark mode via `dark:`; prefer components over ad-hoc CSS.

## Testing Requirements

- `describe`/`it` blocks with descriptive names (reads as a specification)
- Every test has a comment: **Why important** + **What it tests**
- React Testing Library for component tests (test behavior, not implementation)
- **Test doubles (two tiers):** unit mocks the boundary (`vi.mock` / `vi.fn`). A Node/service integration test that needs a backing service runs it in a Docker container via `@testcontainers/postgresql` (or core `testcontainers` `GenericContainer`) — never a hand-rolled fake or in-memory substitute (`must_fix`). A frontend integration test may mock the HTTP boundary with **MSW** (Mock Service Worker); browser E2E is Playwright.
- Test file pattern: `<file>.test.ts` or `<file>.spec.ts` colocated with source
- Shared test utilities in `tests/helpers/` or `__tests__/helpers/`

## Documentation Requirements

- JSDoc on every export
- Services/shared packages: contract `interface` + `kind`/`Config`/`fromConfig` factory with a stub default and exhaustive `switch`; constructor injection at one composition root; config validated once; env read only in the config module; errors carry a `code`
- TSDoc for library packages (`@param`, `@returns`, `@example`)
- Inline comments for non-obvious logic only
- No comments that restate the code
- No issue-tracker IDs in comments; link only committed in-repo docs under `docs/`

## Quality Gates

1. `prettier --check` — code formatting
2. `eslint` — linting
3. `tsc --noEmit` — type checking (strict mode)
4. `vitest run` — all tests pass
5. `vitest run --coverage` — coverage report
