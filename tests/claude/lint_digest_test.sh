#!/usr/bin/env bash
# Tests for .claude/scripts/lint_digest.py, the SessionStart hook that
# summarizes a repo's lint configs (limits and project-specific bans) into the
# session context, so Claude writes code that passes them up front.
set -uo pipefail
# shellcheck source=../lib/assert.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/assert.sh"

DIGEST="$REPO_ROOT/.claude/scripts/lint_digest.py"

# Runs the hook with a SessionStart payload whose cwd is $T/r/${1-} (a git
# repo rooted at $T/r); stdout only.
digest() {
  git -c init.defaultBranch=main init -q "$T/r" 2>/dev/null
  jq -cn --arg d "$T/r/${1-}" '{cwd: $d, source: "startup"}' | python3 "$DIGEST"
}

# Why this test is important:
#   - The bans and limits a golangci config adds are exactly what a model
#     cannot guess; without them it writes fmt.Errorf or a 90-line function
#     and learns about it from the linter afterwards.
# What it tests:
#   - A v2 .golangci.yml yields its limits (lll, funlen, gocyclo), every
#     forbidigo pattern with its message, and every depguard deny with its
#     description, even when the session starts in a subdirectory.
test_golangci_limits_and_bans() {
  mkdir -p "$T/r/pkg"
  cat > "$T/r/.golangci.yml" <<'EOF'
version: "2"
linters:
  default: standard
  enable: [funlen, forbidigo, depguard]
  settings:
    lll:
      line-length: 120
    funlen:
      lines: 60
      statements: 40
    gocyclo:
      min-complexity: 15
    forbidigo:
      forbid:
        - pattern: ^fmt\.Errorf$
          msg: wrap with errs.Wrap so the error carries a code
    depguard:
      rules:
        main:
          deny:
            - pkg: github.com/pkg/errors
              desc: use the coded errs package
EOF
  local out
  out=$(digest pkg)
  assert_contains "$out" ".golangci.yml" "names the config"
  assert_contains "$out" "line-length 120" "lll"
  assert_contains "$out" "lines 60" "funlen lines"
  assert_contains "$out" "min-complexity 15" "gocyclo"
  assert_contains "$out" '^fmt\.Errorf$' "forbidigo pattern"
  assert_contains "$out" "wrap with errs.Wrap" "forbidigo message"
  assert_contains "$out" "github.com/pkg/errors" "depguard pkg"
  assert_contains "$out" "use the coded errs package" "depguard desc"
}

# Why this test is important:
#   - Ruff's select/ignore set and banned APIs decide what Python is legal in
#     the repo; the type checker's mode decides how strictly to annotate.
# What it tests:
#   - pyproject.toml's [tool.ruff] yields line-length, select, ignore and each
#     banned-api entry with its message; [tool.basedpyright] yields its mode.
test_ruff_and_basedpyright() {
  mkdir -p "$T/r"
  cat > "$T/r/pyproject.toml" <<'EOF'
[project]
name = "x"

[tool.ruff]
line-length = 100

[tool.ruff.lint]
select = ["ALL"]
ignore = ["D203", "COM812"]

[tool.ruff.lint.flake8-tidy-imports.banned-api]
"requests".msg = "use httpx"

[tool.basedpyright]
typeCheckingMode = "strict"
EOF
  local out
  out=$(digest)
  assert_contains "$out" "line-length 100" "ruff line-length"
  assert_contains "$out" "select ALL" "ruff select"
  assert_contains "$out" "ignore D203, COM812" "ruff ignore"
  assert_contains "$out" "requests" "banned api"
  assert_contains "$out" "use httpx" "banned api message"
  assert_contains "$out" "typeCheckingMode strict" "basedpyright mode"
}

# Why this test is important:
#   - Semgrep rules are the repo's own invariants; eslint flat configs are
#     code the hook cannot evaluate, so the digest must at least point at them.
# What it tests:
#   - Each semgrep rule id appears with its message, and an eslint.config.js
#     is listed by path.
test_semgrep_rules_and_eslint_pointer() {
  mkdir -p "$T/r/.semgrep" "$T/r/web"
  cat > "$T/r/.semgrep/rules.yml" <<'EOF'
rules:
  - id: no-raw-sql
    message: build queries through the repository layer
    languages: [python]
    severity: ERROR
    pattern: cursor.execute(...)
EOF
  : > "$T/r/web/eslint.config.js"
  local out
  out=$(digest)
  assert_contains "$out" "no-raw-sql" "semgrep id"
  assert_contains "$out" "build queries through the repository layer" "semgrep message"
  assert_contains "$out" "web/eslint.config.js" "eslint config path"
}

# Why this test is important:
#   - Real repos vendor whole semgrep rule packs and write one depguard deny
#     per layer pair; listed one per line they blow the output cap and bury
#     the repo's own rules (seen on a repo with 300+ community rules).
# What it tests:
#   - Rules under a community/ directory collapse to one count line (their
#     ids omitted) while the repo's own rule is still listed; a depguard rule
#     with several denies is one line naming each package once; past 10
#     depguard rules the rest are one count line.
test_vendored_rules_and_depguard_collapse() {
  mkdir -p "$T/r/.semgrep/rules/community/go" "$T/r/.semgrep/rules/own"
  local i
  for i in 1 2 3; do
    printf 'rules:\n  - id: vendored-%s\n    message: generic\n' "$i" > "$T/r/.semgrep/rules/community/go/v$i.yaml"
  done
  printf 'rules:\n  - id: kind-literal\n    message: select backends by Kind\n' > "$T/r/.semgrep/rules/own/k.yaml"
  cat > "$T/r/.golangci.yml" <<'EOF'
version: "2"
linters:
  settings:
    depguard:
      rules:
        core-no-upper:
          deny:
            - pkg: example.com/m/pkg/clients
              desc: core must not import clients
            - pkg: example.com/m/pkg/services
              desc: core must not import services
EOF
  for i in $(seq 1 11); do
    printf '        r%s:\n          deny:\n            - pkg: example.com/m/x%s\n' "$i" "$i" >> "$T/r/.golangci.yml"
  done
  local out
  out=$(digest)
  assert_contains "$out" "kind-literal: select backends by Kind" "own rule listed"
  assert_not_contains "$out" "vendored-1" "vendored ids omitted"
  assert_contains "$out" "3 vendored rules" "vendored count"
  assert_eq 1 "$(grep -c 'depguard\[core-no-upper\]' <<<"$out")" "one depguard line per rule"
  assert_contains "$out" "clients" "first denied package"
  assert_contains "$out" "services" "second denied package"
  assert_not_contains "$out" "depguard[r10]" "rules past the cap omitted"
  assert_contains "$out" "2 more depguard rules" "depguard overflow count"
}

# Why this test is important:
#   - Every session pays for SessionStart output; a repo with no lint config
#     (or no repo at all) must cost nothing.
# What it tests:
#   - No lint configs gives empty stdout and exit 0, as does a cwd outside git
#     and a config with nothing to report (a [tool.ruff] that only extends a
#     shared config).
test_nothing_to_say() {
  local out rc
  out=$(digest)
  rc=$?
  assert_eq 0 "$rc" "exit status"
  assert_eq "" "$out" "stdout"
  mkdir -p "$T/r/svc"
  printf '[tool.ruff]\nextend = "../ruff.toml"\n' > "$T/r/svc/pyproject.toml"
  assert_eq "" "$(digest)" "stdout for a bare [tool.ruff]"
  out=$(jq -cn --arg d "$T" '{cwd: $d}' | python3 "$DIGEST")
  assert_eq "" "$out" "stdout outside git"
}

run_test test_golangci_limits_and_bans
run_test test_ruff_and_basedpyright
run_test test_semgrep_rules_and_eslint_pointer
run_test test_vendored_rules_and_depguard_collapse
run_test test_nothing_to_say
finish
