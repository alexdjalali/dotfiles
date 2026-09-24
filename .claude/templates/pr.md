# Pull Request Template

## Title Format

```
<type>(<scope>): <short description>
```

Same types as conventional commits. Max 72 chars.

## Body Template

```markdown
## Summary

<!-- 1-3 bullet points: what this PR does and WHY -->

-

## Changes

<!-- Group by area. Include file paths for significant changes. -->

### <Area 1>
-

### <Area 2>
-

## References

<!-- Link to spec pipeline artifacts if they exist. Plans are gitignored and local-only:
     name the plan for traceability, but don't link it as if reviewers can open it. -->

- Plan (local-only, not in the repo): `YYYY-MM-DD-<slug>`
- Story: `docs/spec/stories/N.M-<slug>.md`
- Epic: `docs/spec/epics/epic-NN-<slug>.md`
- ADR: `docs/adr/NNNN-<title>.md`

## Test Plan

<!-- How was this tested? What should reviewers verify? -->

- [ ] Unit tests pass (`uv run pytest` / `go test` / `vitest`)
- [ ] Lint clean (`ruff check` / `golangci-lint` / `eslint`)
- [ ] Type check clean (`basedpyright` / `go vet` / `tsc --noEmit`)
- [ ] Manual verification: <describe what to try>

## Screenshots / Output

<!-- If UI or CLI output changed, show before/after -->

## Checklist

- [ ] Conventional commit messages on all commits
- [ ] No secrets or credentials in diff
- [ ] No TODO/FIXME without linked issue
- [ ] Documentation updated (if public API changed)
```
