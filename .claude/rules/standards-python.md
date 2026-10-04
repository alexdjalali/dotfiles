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

**Mandatory mocking in unit tests** (mock at module level — where imported, not where defined; a test > 1 s is likely unmocked I/O):

| Call | MUST mock | Example |
|------|-----------|---------|
| HTTP/network | `httpx`, `requests` | `@patch("module.httpx.Client")` |
| Subprocess | `subprocess.run` | `@patch("module.subprocess.run")` |
| File I/O | `open`, `Path.read_text` | `@patch("builtins.open")` or `tmp_path` |
| Database | SQLite, PostgreSQL | test fixtures (integration: testcontainers) |
| External APIs | any third-party | mock the client |

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
- **Logging:** `structlog` (structured, context-bound) — never `print()` in production.
- **HTTP:** `httpx` (async-capable). **Ruff:** the project's `pyproject.toml` (line length commonly 88–110; `select = ["ALL"]` with documented ignores where the project uses it).

### Code Style

- **Type hints** on every public function; modern syntax (`list[int]`, `Item | None`). Contracts are `typing.Protocol`s in the core package; a local protocol extends the core one.
- **Imports:** absolute; no cross-package relative imports. Heavy backend dependencies are imported inside the factory branch that needs them.
- **Guard clauses** over nesting. Comments only for non-obvious logic.

### Documentation

- A module docstring on every file.
- Every public class, function, and method has a docstring — one line unless the logic needs Google-style `Args`/`Returns`/`Raises`. Every model/config field is documented (`Field(..., description=...)` or an attribute docstring); trivially obvious fields are exempt.
- Revise a docstring when you edit its symbol — never delete it. Tracker IDs and link rules: `documentation-sync.md`.

### Errors

- **Errors carry a code:** raise or `wrap(...)` into the project's `AppError` hierarchy; transient/permanent and the HTTP/gRPC status derive from the code; the transport edge sanitizes the message.
- No bare `except:`; catch the specific exception, then wrap with a code or re-raise. Never swallow.

### Factories, DI, and decorators

```python
class StoreKind(StrEnum):
    """Names a Store backend."""

    STUB = "stub"
    """Zero-I/O default, so the graph boots with no infrastructure."""

    POSTGRES = "postgres"
    """Rows in PostgreSQL."""


@dataclass(frozen=True, slots=True)
class StoreConfig:
    """Selects and configures a Store backend; holds every kind's settings."""

    kind: StoreKind = StoreKind.STUB
    """Which backend to build."""

    dsn: str = ""
    """Connection string for POSTGRES."""


def store_from_config(cfg: StoreConfig) -> Store:
    """Return the Store backend ``cfg.kind`` names; fail loudly on an unknown kind."""
    match cfg.kind:
        case StoreKind.STUB:
            return StubStore()
        case StoreKind.POSTGRES:
            from app.clients.store.postgres import PostgresStore  # heavy dep, lazy

            return PostgresStore(cfg.dsn)
        case _:
            raise AppError(ErrorCode.INVALID_CONFIG, f"store: unknown kind {cfg.kind!r}")
```

- **Composition root:** one `deps.py` per deployable builds the graph from settings — constructor injection only, no I/O at import or construction, no module-level singletons; lifetimes and teardown live there (FastAPI lifespan / `Depends` reads from it).
- **Decorators** (logging, tracing, metrics, retry with backoff + jitter on transient codes, circuit breaker, timeout) are proxies that wrap the protocol at the composition root, in the per-layer order (`CLAUDE.md` *Architecture*) — never inlined in a backend, never doubled over an SDK that already retries.

### Configuration

- `pydantic-settings` `BaseSettings` loads layered YAML (`base` → env overlay → gitignored secrets) with env-var overrides, validated at startup. Every field is `Field(default, description=...)` with a fail-safe `base` value.
- Each tier exposes a `*_config()` builder that maps settings onto its frozen `Config`; `os.environ` is read only in the config layer or entrypoints.

### Observability

- `structlog` bound with request/trace IDs; OpenTelemetry spans on every boundary; metrics through the metrics decorator.
- Health and readiness endpoints; readiness flips before the drain; graceful shutdown cancels and awaits tasks.

### Code generation

- Contract-derived code (protobuf/gRPC stubs, API clients, models from a schema) comes from the project's generator via its CLI (e.g. `buf generate`); output is committed, carries a generated header, is excluded from lint, and is never hand-edited. CI regenerates and fails on drift.
- A repeated shape with no off-the-shelf generator is a template (e.g. Jinja2) behind a CLI subcommand, not copy-paste.

### Common Patterns

- **Context managers** for resources; **`pathlib`** over `os.path`.

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
- [ ] Generated code in sync with its source
- [ ] Production files ideally under 800 lines (generated files exempt)
