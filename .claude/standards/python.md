# Python Standards (3.14+)

## Tooling
- Package manager: `uv` (never pip/poetry)
- Lint + format: `ruff check` + `ruff format`
- Type check: `basedpyright` (strict) or `mypy --strict`
- Test: `pytest` with markers per layer (unit, integration, e2e)

## Code Style
- Models: `@attrs.define(frozen=True, slots=True)` or frozen dataclasses
- Async: `async def` + `await`; `asyncio.run()` only at boundaries
- Imports: absolute only; no cross-package relative imports
- Docstrings: Google style. Line length: 100.
- No `print()` in production; use structured logging
- No bare `except:`

## Testing Requirements
- Class-based test organization with descriptive method names
- Every test has a docstring: **Why important** + **What it tests**
- `conftest.py` fixtures: global at `tests/unit/conftest.py`, per-service in subdirectories
- `hypothesis` for property-based testing (pure functions, roundtrips, invariants)
- `pytest` markers per layer: `@pytest.mark.unit`, `@pytest.mark.integration`, `@pytest.mark.e2e`
- Test file pattern: `test_<module>.py` in `tests/` directory

## Documentation Requirements
- Module-level docstrings on all files (summary, coverage, structure)
- Google-style docstrings on all public classes, methods, and functions
- Inline comments for non-obvious logic only
- Type hints on all public APIs (`basedpyright` strict compliance)

## Quality Gates (pre-commit hooks)
1. `uv sync --frozen` — lockfile consistency
2. `ruff format --check` — code formatting
3. `ruff check` — lint (51 rule categories)
4. `basedpyright` or `mypy --strict` — type checking
5. `codespell` — typo detection
6. `pytest` (unit) — unit tests pass
7. `pytest` (integration) — integration tests pass
8. `pip-audit` — CVE scanning

Run all: `uv run pre-commit run --all-files`
