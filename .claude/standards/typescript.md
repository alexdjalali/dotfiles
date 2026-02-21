# TypeScript / React / Next.js Standards

## Tooling
- Package manager: `pnpm` (never npm/yarn)
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
- Memoization: `useMemo`/`useCallback` only when profiling shows a need, not by default
- Component files: one exported component per file; colocate styles and tests
- Error boundaries for failure isolation at route/feature level

## Tailwind CSS
- Use utility classes directly; avoid `@apply` except in base/component layers
- Extract repeated patterns into React components, not CSS classes
- Responsive: mobile-first (`sm:`, `md:`, `lg:` breakpoints)
- Dark mode: use `dark:` variant consistently
- Custom values: extend theme in `tailwind.config.ts` rather than arbitrary values `[...]`
- Class ordering: follow Tailwind Prettier plugin ordering
- No inline `style={}` when Tailwind utilities exist
