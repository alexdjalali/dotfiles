---
paths:
  - "**/models/**"
  - "**/models.py"
  - "**/schema.prisma"
  - "**/schema/**"
  - "**/entities/**"
  - "**/*.sql"
  - "**/queries/**"
  - "**/repository/**"
  - "**/repositories/**"
  - "**/dao/**"
  - "**/migrations/**"
  - "**/migrate/**"
  - "**/alembic/**"
  - "**/db/migrate/**"
  - "**/routes/**"
  - "**/api/**"
  - "**/controllers/**"
  - "**/endpoints/**"
  - "**/handlers/**"
---

# Backend Standards

## API Design

- **RESTful:** Resource-based URLs (`GET /users`, `POST /users`, `PUT /users/{id}`). Plural nouns, limit nesting to 2-3 levels.
- **Query params:** Filtering (`?status=active`), sorting (`?sort=created_at`), pagination (`?page=2&limit=50`)
- **Status codes:** `200` OK, `201` Created, `204` No Content | `400`/`401`/`403`/`404`/`409`/`422` | `500`/`503`
- **Response structure:** `{ "data": {...} }` for success, `{ "error": { "code": "...", "message": "..." } }` for errors
- **Validation:** at the API boundary, through one chokepoint; request/response DTOs generated from the contract (proto / OpenAPI) where the project has one. Never expose internal errors (stack traces, DB errors) — the error `code` maps to the status, the message is sanitized.
- **Contract first:** the endpoint is defined in the contract, handlers and clients are generated from it, and a breaking-change check runs in CI.

## Resilience

- **Timeouts:** every external call has a chosen deadline, propagated through the context.
- **Retry** only transient error codes, with exponential backoff + jitter and a cap; idempotent operations only (or with an idempotency key). Don't stack a retry over an SDK that already retries.
- **Circuit breaker** per failure domain; **bulkhead** / concurrency limit per downstream; **rate limit** at the edge; graceful degradation when a dependency is down.
- **Messaging:** transactional outbox for publish-after-write; consumers dedupe (idempotent handlers) and dead-letter after bounded retries.
- All of the above are decorators applied at the composition root in the per-layer order (`CLAUDE.md` *Architecture*), never inlined in a handler or repository.

## Observability

- Structured JSON logs with request and trace IDs; no secrets or PII in logs.
- RED metrics (rate, errors, duration) per endpoint and per downstream; OpenTelemetry spans across every boundary with trace context propagated.
- `/healthz` (liveness) and `/readyz` (readiness, flips false before drain); graceful shutdown drains in-flight work within a deadline.

## Models

**Models define data structure and integrity. No business logic, no API calls.**

- **Naming:** Models: singular PascalCase (`User`). Tables: plural snake_case (`users`).
- **Required:** `created_at`/`updated_at` timestamps, explicit primary keys
- **Integrity at DB level:** `unique`, `nullable=False`, `CheckConstraint`, `ForeignKey` with explicit `ondelete`
- **Data types:** Money → DECIMAL not FLOAT. Timestamps → TIMESTAMP not VARCHAR. JSON → JSONB not TEXT. UUIDs → UUID not VARCHAR(36).
- **Indexes:** On foreign keys and WHERE/JOIN/ORDER BY columns. Don't over-index.
- **Scope:** Fields, relationships, properties, validation. NOT business logic, API calls, calculations.

## Queries

- **⛔ SQL injection prevention:** NEVER concatenate user input. Always parameterized queries or ORM methods.
- **N+1 prevention:** `joinedload` for one-to-one, `selectinload` for large collections
- **Performance:** Select only required columns, filter in DB not app, avoid leading wildcards
- **Query timeouts:** Simple 1-2s, reports 10-30s, background 60s+
- **Transactions:** For multiple related writes and read-then-write (`FOR UPDATE`)
- **Integration-test against a real DB container** (testcontainers), never SQLite-for-Postgres or an in-memory substitute — SQL dialect, constraints, migrations, and transaction semantics do not survive the swap. See `testing.md` *Test Double Policy*.

## Migrations

- **Reversible:** Every migration MUST have a working rollback
- **One change per migration.** Never modify deployed migrations.
- **Naming:** Timestamps + descriptive: `20241118120000_add_email_to_users.py`
- **NOT NULL columns:** Always specify `server_default`
- **Removing columns:** Multi-step — stop using it in code first, then remove
- **Indexes:** Concurrent creation on large tables
- **Data migrations:** Separate from schema changes, batch process, make idempotent
- **Zero-downtime:** Migration must work with currently deployed code

## Checklist

- [ ] REST principles, correct status codes; contract updated and code regenerated
- [ ] External calls: timeout, retry on transient codes only, breaker — via decorators
- [ ] Logs, metrics, spans on new paths; health/readiness unaffected or extended
- [ ] All user input parameterized
- [ ] Models: timestamps, constraints, appropriate types
- [ ] No N+1 queries, only required columns
- [ ] Migrations: reversible, one change each, backwards compatible
- [ ] Performance: hot-path results cached, no redundant I/O per request, heavy computations async
- [ ] Tested: success and error cases; repository/query/migration behavior covered by integration tests against a real DB container (testcontainers), not an in-memory substitute
