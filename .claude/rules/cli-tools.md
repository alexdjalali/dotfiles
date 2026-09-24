## CLI Tools

**⛔ Prefer CLIs.** When a tool or service exposes a CLI, default to its CLI commands over ad-hoc API calls, manual file edits, or reimplementing its behavior — the CLI encodes the supported, correct workflow (auth, validation, side-effects, idempotency). Before hand-rolling, check for one: `<tool> --help`, `which <tool>`, and the project's `Makefile` / `package.json` scripts / `justfile`. Only drop to raw API/file manipulation when no CLI covers the task.

RTK (the token-saving CLI proxy): `RTK.md`. Semble CLI: `mcp-servers.md`.
