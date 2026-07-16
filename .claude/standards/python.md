# Python Standards (3.12)

Grounded in the flagship repo **bloodhound-search-platform** (`pkg/python`, e.g. `techai_webutils`). Match how we do things there.

## Tooling
- Package manager: `uv` (never pip/poetry)
- Lint + format: `ruff check` + `ruff format` (**line length 110**)
- Type check: `basedpyright` (strict) or `mypy --strict`
- Test: `pytest` (9+) with `pytest-asyncio`, `pytest-cov`, and markers per layer (unit, integration, e2e)
- Target runtime: `requires-python ~= 3.12`

## Code Style
- **Validated / boundary models & config: `pydantic` v2** (`BaseModel`, `pydantic-settings` `BaseSettings`). Use `@attrs.define(frozen=True, slots=True)` or frozen dataclasses for internal value objects that don't need validation.
- Logging: **`structlog`** (structured); never `print()` in production
- HTTP: `httpx` (async-capable)
- Async: `async def` + `await`; `asyncio.run()` only at boundaries
- Imports: absolute only; no cross-package relative imports
- Docstrings: Google style
- No bare `except:`

## Testing Requirements
- Class-based test organization with descriptive method names
- Every test has a docstring: **Why important** + **What it tests**
- `conftest.py` fixtures: global at `tests/unit/conftest.py`, per-service in subdirectories
- **Test doubles: mocks and fixtures, not fakes.** Mock the external boundary (`unittest.mock` / `pytest` monkeypatch) and reuse the project's `conftest.py` fixtures. Do not hand-roll an in-memory fake of a dependency when a mock or fixture will serve.
- `hypothesis` for property-based testing (pure functions, roundtrips, invariants)
- `pytest` markers per layer: `@pytest.mark.unit`, `@pytest.mark.integration`, `@pytest.mark.e2e`
- Test file pattern: `test_<module>.py` in `tests/` directory

## Documentation Requirements
- Module-level docstrings on all files (summary, coverage, structure)
- Google-style docstrings on all public classes, methods, and functions
- Inline comments for non-obvious logic only
- Type hints on all public APIs (`basedpyright` strict compliance)
- A code change updates every docstring / README / architecture doc that references it, **directly or indirectly** (a caller or documented behavior that depends on it)

## Flagship Patterns

Our engineering standards are catalogued in two posts; the standards above are the day-to-day subset:
- [The Top 50 Techniques for Distributed Engineering](https://alexdjalali.github.io/posts/top-50-techniques-for-distributed-engineering/)
- [100 Patterns for Production Go and Python](https://alexdjalali.github.io/posts/100-patterns-for-production-go-and-python/)

Known gaps in the flagship repo — reach for these when the task touches the relevant path (don't add speculatively, YAGNI): backpressure-aware processing on message consumers (#65), object/buffer pooling on the parse/embedding hot path (#70/#73), and golden-file testing for generated and extracted outputs (#82).

## Quality Gates (pre-commit hooks)
1. `uv sync --frozen` — lockfile consistency
2. `ruff format --check` — code formatting
3. `ruff check` — lint
4. `basedpyright` or `mypy --strict` — type checking
5. `codespell` — typo detection
6. `pytest` (unit) — unit tests pass
7. `pytest` (integration) — integration tests pass
8. `pip-audit` — CVE scanning

Run all: `uv run pre-commit run --all-files`
