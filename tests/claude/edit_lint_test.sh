#!/usr/bin/env bash
# Tests for .claude/scripts/edit-lint.sh, the PostToolUse hook that formats an
# edited file, then runs the project's own linter on it and feeds the findings
# back to Claude (stderr + exit 2). The linters and formatters are PATH mocks:
# the tests pin which tool runs, where, on what, and what reaches Claude.
set -uo pipefail
# shellcheck source=../lib/assert.sh
source "$(dirname "${BASH_SOURCE[0]}")/../lib/assert.sh"

HOOK="$REPO_ROOT/.claude/scripts/edit-lint.sh"

# Runs the hook on an Edit of $1 whose new_string is $2; stderr -> $T/err.
# Prints the exit status.
edit() {
  jq -cn --arg f "$1" --arg n "${2-x = 1}" '{tool_name: "Edit", tool_input: {file_path: $f, old_string: "", new_string: $n}}' |
    bash "$HOOK" >"$T/out" 2>"$T/err"
  echo $?
}

# Stubs every formatter so no real one rewrites the test files.
stub_formatters() {
  mock_cmd gofumpt
  mock_cmd prettier
}

# Why this test is important:
#   - The point of the hook: a lint violation reaches Claude on the edit that
#     made it, not at the pre-commit fast checks after the code is written.
# What it tests:
#   - In a project whose pyproject.toml configures ruff, the hook runs
#     `ruff check` on the edited file and returns its findings on stderr with
#     exit 2.
test_ruff_findings_reach_claude() {
  stub_formatters
  mkdir -p "$T/p/src"
  printf '[tool.ruff]\nline-length = 88\n' > "$T/p/pyproject.toml"
  : > "$T/p/src/m.py"
  mock_cmd ruff "src/m.py:1:1: T201 \`print\` found" 1
  assert_eq 2 "$(edit "$T/p/src/m.py")" "exit status"
  assert_contains "$(cat "$T/err")" "T201" "stderr carries the finding"
  assert_contains "$(mock_calls ruff)" "check" "ruff check ran"
  assert_contains "$(mock_calls ruff)" "$T/p/src/m.py" "on the edited file"
}

# Why this test is important:
#   - A clean edit must stay silent, or Claude learns to ignore the channel.
# What it tests:
#   - ruff check exiting 0 gives exit 0 and no output.
test_clean_lint_is_silent() {
  stub_formatters
  mkdir -p "$T/p"
  printf '[tool.ruff]\n' > "$T/p/pyproject.toml"
  : > "$T/p/m.py"
  mock_cmd ruff "" 0
  assert_eq 0 "$(edit "$T/p/m.py")" "exit status"
  assert_eq "" "$(cat "$T/out" "$T/err")" "output"
}

# Why this test is important:
#   - Ruff's defaults are not the project's rules; linting a repo that never
#     opted in would push Claude to "fix" code against rules nobody chose.
# What it tests:
#   - A .py file with no ruff config above it (a pyproject.toml without
#     [tool.ruff] does not count) never runs ruff check.
test_no_config_no_lint() {
  stub_formatters
  mkdir -p "$T/p"
  printf '[project]\nname = "x"\n' > "$T/p/pyproject.toml"
  : > "$T/p/m.py"
  mock_cmd ruff "" 1
  assert_eq 0 "$(edit "$T/p/m.py")" "exit status"
  assert_not_contains "$(mock_calls ruff)" "check" "ruff calls"
}

# Why this test is important:
#   - Lint must see the formatted file: run in parallel, a line-length finding
#     the formatter is about to fix would send Claude after a non-problem.
# What it tests:
#   - ruff format runs on the file before ruff check.
test_formats_before_linting() {
  stub_formatters
  mkdir -p "$T/p"
  printf '[tool.ruff]\n' > "$T/p/pyproject.toml"
  : > "$T/p/m.py"
  mock_cmd ruff "" 0
  edit "$T/p/m.py" >/dev/null
  assert_eq "format" "$(mock_calls ruff | head -n 1 | cut -d' ' -f1)" "first ruff call"
  assert_contains "$(mock_calls ruff | tail -n 1)" "check" "last ruff call"
}

# Why this test is important:
#   - golangci-lint works on packages, not files, and only inside the module;
#     run elsewhere it fails on every edit.
# What it tests:
#   - With a .golangci.yml at the module root, an edit to pkg/a/a.go runs
#     `golangci-lint run ./pkg/a` from the module root and returns its
#     findings with exit 2.
test_golangci_runs_on_the_package() {
  stub_formatters
  mkdir -p "$T/m/pkg/a"
  printf 'version: "2"\n' > "$T/m/.golangci.yml"
  printf 'module example.com/m\n' > "$T/m/go.mod"
  printf 'package a\n' > "$T/m/pkg/a/a.go"
  cat > "$MOCK_BIN/golangci-lint" <<EOF
#!/usr/bin/env bash
echo "\$PWD \$*" >> "$MOCK_DIR/golangci.calls"
echo "a.go:1:1: funlen"
exit 1
EOF
  chmod +x "$MOCK_BIN/golangci-lint"
  assert_eq 2 "$(edit "$T/m/pkg/a/a.go" "package a")" "exit status"
  assert_eq "$T/m run ./pkg/a" "$(cat "$MOCK_DIR/golangci.calls")" "cwd and args"
  assert_contains "$(cat "$T/err")" "funlen" "stderr carries the finding"
}

# Why this test is important:
#   - eslint must be the project's own install: `npx eslint` would download
#     an arbitrary version on every edit, and a global one ignores the
#     project's plugins.
# What it tests:
#   - With eslint.config.js and node_modules/.bin/eslint at the root, a .ts
#     edit runs that binary on the file; without the local binary, nothing runs.
test_eslint_uses_the_project_binary() {
  stub_formatters
  mkdir -p "$T/w/src" "$T/w/node_modules/.bin"
  : > "$T/w/eslint.config.js"
  : > "$T/w/src/a.ts"
  cat > "$T/w/node_modules/.bin/eslint" <<EOF
#!/usr/bin/env bash
echo "\$*" >> "$MOCK_DIR/eslint.calls"
echo "no-restricted-imports"
exit 1
EOF
  chmod +x "$T/w/node_modules/.bin/eslint"
  assert_eq 2 "$(edit "$T/w/src/a.ts" "const a = 1")" "exit status"
  assert_contains "$(cat "$MOCK_DIR/eslint.calls")" "$T/w/src/a.ts" "eslint args"
  rm "$T/w/node_modules/.bin/eslint"
  assert_eq 0 "$(edit "$T/w/src/a.ts" "const a = 1")" "exit status without a local eslint"
}

# Why this test is important:
#   - A Write creates or replaces a whole file; skipping it would leave every
#     new file unlinted until commit.
# What it tests:
#   - A Write payload (content, no new_string) lints the file too.
test_write_is_linted() {
  local rc
  stub_formatters
  mkdir -p "$T/p"
  printf '[tool.ruff]\n' > "$T/p/pyproject.toml"
  : > "$T/p/m.py"
  mock_cmd ruff "m.py:1:1: E501" 1
  jq -cn --arg f "$T/p/m.py" '{tool_name: "Write", tool_input: {file_path: $f, content: "x = 1\n"}}' |
    bash "$HOOK" >"$T/out" 2>"$T/err"
  rc=$?
  assert_eq 2 "$rc" "exit status"
  assert_contains "$(cat "$T/err")" "E501" "stderr"
}

# Why this test is important:
#   - A Write rewrites the whole file; judged against nothing, every print()
#     the file already had would warn on each rewrite and train Claude to
#     ignore the warning.
# What it tests:
#   - A Write whose result carries the prior file (tool_response.originalFile)
#     warns only about a print() it adds; a Write creating a file
#     (originalFile null) warns about the print() it brings.
test_write_compares_against_the_original_file() {
  local rc
  stub_formatters
  mock_cmd ruff
  printf 'print("old")\n' > "$T/m.py"
  jq -cn --arg f "$T/m.py" '{tool_name: "Write", tool_input: {file_path: $f, content: "print(\"old\")\nx = 1\n"}, tool_response: {type: "update", originalFile: "print(\"old\")\n"}}' |
    bash "$HOOK" >"$T/out" 2>"$T/err"
  rc=$?
  assert_eq 0 "$rc" "exit status when the print() was already there"
  jq -cn --arg f "$T/m.py" '{tool_name: "Write", tool_input: {file_path: $f, content: "print(\"old\")\n"}, tool_response: {type: "create", originalFile: null}}' |
    bash "$HOOK" >"$T/out" 2>"$T/err"
  rc=$?
  assert_eq 2 "$rc" "exit status on a new file"
  assert_contains "$(cat "$T/err")" "print() found" "stderr on a new file"
}

run_test test_ruff_findings_reach_claude
run_test test_clean_lint_is_silent
run_test test_no_config_no_lint
run_test test_formats_before_linting
run_test test_golangci_runs_on_the_package
run_test test_eslint_uses_the_project_binary
run_test test_write_is_linted
run_test test_write_compares_against_the_original_file
finish
