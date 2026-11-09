# Cross-Cutting Trace

A change is rarely confined to the layer it starts in. Compilers and unit tests see that first layer only, so what gets forgotten is everything after it: the registry, the grant, the migration order, the dashboard. This trace is the one place the layers are listed. Skills point here and do not copy it.

A repo's `.claude/rules/cross-cutting.md`, when present, maps these rows to its real paths, commands and guards, and may add rows or name a skill that walks them. Follow it.

## When

Walk it **when planning, before committing, and when reviewing**, if the change:

- adds, renames or removes a deployable (service, worker, job, image, CLI, package);
- gains an external call, queue, bucket, table, secret, port, or service-to-service call;
- changes a public contract, a persisted format, a schema, or an auth rule;
- adds or changes a config field, a feature flag, or a default;
- touches infrastructure, CI/CD, deploy manifests, or a generator's source.

None apply → record `Cross-cutting: none (<reason>)`. Review checks that claim against the diff.

## The layers

Start from the blast radius (`codegraph_impact`, `codegraph_callers`, then Grep for name lists and dynamic references, which a code graph can't see). Then write one line for **every** row: `done` (`file:line`), `not needed` (with the reason), or `gap`. **Silence is a gap.** "Not needed" with no reason is a gap.

| # | Layer | Ask | Fails how if forgotten |
|---|-------|-----|------------------------|
| 1 | Callers and parallels | Every caller updated? Every parallel implementation of this logic changed too? | The one you missed keeps the old behavior |
| 2 | Contracts and generated code | Schema/proto/OpenAPI changed at the source and regenerated? Old and new readers and writers compatible during the rollout? | Version skew breaks one side mid-deploy |
| 3 | Data | Migration ordered before the code needs it? Expand then contract? Backfill? Reversible? | Old pods crash on the new schema, or the rollback can't run |
| 4 | Config | Field in the schema, `base` default, every env overlay that differs, generated config docs? | Boots in dev, fails or silently defaults elsewhere |
| 5 | Secrets | Created in the store, delivered to the workload, in the example file, rotation owner known? | Missing at startup in the first real environment |
| 6 | Identity and permissions | Cloud grant for the action **and** resource, CI role or token scope, app authorization, tenant scoping on every new query or path? | Denied at runtime only, or worse, allowed across tenants |
| 7 | Network | Port, service definition, mesh or firewall allow, gateway route, DNS, CORS? | Default-deny drops the traffic |
| 8 | Build and registry | Build target, image repository, lock file, base image pin? | Never built, or the push fails |
| 9 | CI/CD | Job, matrix and path filters reach it? Right trigger? Right role? | The pipeline is green and skips it |
| 10 | Infrastructure as code | The resource exists in IaC, for every account and region? IaC is the source of truth: never console-created. | Works where someone clicked it |
| 11 | Deploy manifests | Chart, overlay per environment, sizing, health probes, autoscaling, disruption budget? | Not deployed in that environment |
| 12 | Environment parity | Local dev stack, test fixtures, seed data, and staging all have it? | Only one environment works |
| 13 | Observability | Logs, metrics, traces, then the dashboard, alert and runbook that use them? | Fails silently, or the alert watches a renamed metric |
| 14 | Guards and tests | Name lists and parity guards updated? The right test tier proves each layer? Two files that must agree: generated or guarded? | Drift returns next change |
| 15 | Docs | Every doc describing this layer refreshed (`documentation-sync.md`)? | The next agent trusts the stale doc |

Rows that keep recurring deserve a check, not a longer list: `/inspect`.

## Rollout

Merging is not deploying. State, in the plan or PR:

1. **Order** — what must be live before what: IaC and permissions, then data, then code that needs them, then traffic. Each deploy step must work with both the old and the new version of its neighbors.
2. **Manual steps** — anything a merge does not do (a dispatch-only apply, a secret to set, a flag to flip), with the exact command and who runs it.
3. **Rollback** — how to undo it, and what cannot be undone (a dropped column, a sent message). Irreversible steps go last and are called out.

## Prove it

Run each layer's own check. Never claim a resource exists or a permission holds from reading the code: query it, or name the exact step still owed.
