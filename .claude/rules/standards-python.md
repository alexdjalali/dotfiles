---
paths:
  - "**/*.py"
---

## Python Development Standards

**Standards:** Always use uv | pytest for tests | ruff for quality | Self-documenting code

### Package Management - UV ONLY

**Use `uv` for all Python operations, not `pip` directly** — `pip` bypasses uv's environment and lockfile management, desyncing the project.

```bash
uv add package-name        # add a project dependency (updates pyproject.toml + lockfile)
uv run python script.py
uv run pytest
```

Use `uv pip install ...` only for the pip-compat shim (installing into an env without touching project metadata); prefer `uv add` for real dependencies.

### Testing & Quality

**Use minimal output flags to avoid context bloat.**

```bash
uv run pytest -q                                    # Quiet mode (preferred)
uv run pytest -q --cov=src                         # Coverage report (gate is per-critical-path; see testing.md)
# AVOID -v, -vv, -s unless actively debugging

ruff format .                                       # Format
ruff check . --fix                                  # Lint
basedpyright src                                    # Type check (adapt to your source dirs)
```

`hypothesis` for property-based testing (pure functions, roundtrips, invariants). `pytest-asyncio` for `async def` tests. Use `@pytest.mark.unit` / `@pytest.mark.integration` / `@pytest.mark.e2e` markers.

**Test doubles (two tiers — see `testing.md` *Test Double Policy*):** **unit** mocks the boundary with `unittest.mock` (`@patch` at the import site) or a mock of a small `Protocol`; **integration** runs the real dependency in a Docker container via `testcontainers`, driven by pytest fixtures. Hand-rolled fakes / in-memory substitutes (SQLite-for-Postgres, `fakeredis`) are a `must_fix`.

### Integration tests (testcontainers)

Add the service extra as a dev dependency, stand the real dependency up in a session-scoped fixture, and mark the tests `@pytest.mark.integration` — never a mock or in-memory substitute.

```bash
uv add --dev "testcontainers[postgres]"   # per service: [redis], [minio], [kafka], …
```

```python
import pytest
from testcontainers.postgres import PostgresContainer


@pytest.fixture(scope="session")
def pg_url() -> str:
    """Real Postgres in a throwaway container; torn down after the session."""
    with PostgresContainer("postgres:16") as pg:
        yield pg.get_connection_url()


@pytest.mark.integration
def test_store_crud_persists_against_real_postgres(pg_url: str) -> None:
    # Why: real SQL + constraints are invisible to a mock.
    # What: create → read round-trips through a live database.
    ...
```

### Libraries

- **Boundary models & config:** `pydantic` v2 (`BaseModel`, `pydantic-settings` `BaseSettings`); frozen dataclasses or `attrs` for internal value objects that don't need validation.
- **Logging:** `structlog` (structured) — never `print()` in production.
- **HTTP:** `httpx` (async-capable). **Ruff line length:** follow the project's `pyproject.toml` (commonly 88–110).

### Code Style

- **Docstrings:** One-line for most functions. Multi-line only for complex logic. Skip when name is self-explanatory.
- **Type hints:** Required on public functions. Use modern syntax: `list[int]`, `Item | None` (not `List`, `Optional`).
- **Imports:** Standard → Third-party → Local. Ruff auto-sorts. Absolute imports; no cross-package relative imports.
- **Comments:** Only for complex algorithms, non-obvious logic, or workarounds.

### Common Patterns

- **No bare `except`:** Catch specific exceptions, log, and re-raise
- **Context managers:** `with open(path) as f:` for resources
- **Pathlib over os.path:** `Path(__file__).parent / "config.yaml"`

### Project Configuration

- Match the project's `requires-python` (don't assume a version); modern targets are 3.12–3.14
- Dependencies in `pyproject.toml`
- Use `@pytest.mark.unit` and `@pytest.mark.integration` markers

### Verification Checklist

- [ ] `uv run pytest` — tests pass
- [ ] `ruff format .` — formatted
- [ ] `ruff check .` — clean
- [ ] `basedpyright src` — clean (adapt to your source dirs)
- [ ] Critical-path coverage adequate (see testing.md "Test Strategy & Coverage")
- [ ] No unused imports
- [ ] Production files ideally under 800 lines (1000+ = consider splitting)
