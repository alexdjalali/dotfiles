---
paths:
  - "**/*.py"
---

## Python Development Standards

**Standards:** Always use uv | pytest for tests | ruff for quality | Self-documenting code

### Package Management - UV ONLY

**Use `uv` for all Python operations, not `pip` directly** — `pip` bypasses uv's environment and lockfile management, desyncing the project.

```bash
uv pip install package-name
uv run python script.py
uv run pytest
```

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

### Code Style

- **Docstrings:** One-line for most functions. Multi-line only for complex logic. Skip when name is self-explanatory.
- **Type hints:** Required on public functions. Use modern syntax: `list[int]`, `Item | None` (not `List`, `Optional`).
- **Imports:** Standard → Third-party → Local. Ruff auto-sorts.
- **Comments:** Only for complex algorithms, non-obvious logic, or workarounds.

### Common Patterns

- **No bare `except`:** Catch specific exceptions, log, and re-raise
- **Context managers:** `with open(path) as f:` for resources
- **Pathlib over os.path:** `Path(__file__).parent / "config.yaml"`

### Project Configuration

- Python 3.12+ (`requires-python = ">=3.12"`)
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
