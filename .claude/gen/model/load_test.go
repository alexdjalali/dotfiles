package model_test

import (
	"os"
	"path/filepath"
	"strings"
	"testing"

	"claudegen/model"
)

// writeFile creates path under root with the given content, creating parents.
func writeFile(t *testing.T, root, path, content string) {
	t.Helper()
	full := filepath.Join(root, path)
	if err := os.MkdirAll(filepath.Dir(full), 0o755); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(full, []byte(content), 0o644); err != nil {
		t.Fatal(err)
	}
}

// TestLoadMissingGenYamlEnablesNothing tests that an empty source tree loads.
//
// Why this test is important:
//   - The fail-safe default must be "render nothing", so a fresh checkout
//     never overwrites hand-written files.
//
// What it tests:
//   - Load on a root without .claude/src/gen.yaml returns no targets and no error.
func TestLoadMissingGenYamlEnablesNothing(t *testing.T) {
	root := t.TempDir()
	m, err := model.Load(root)
	if err != nil {
		t.Fatalf("Load: %v", err)
	}
	if len(m.Gen.Targets) != 0 {
		t.Fatalf("targets = %v, want none", m.Gen.Targets)
	}
	if m.Root != root {
		t.Fatalf("Root = %q, want %q", m.Root, root)
	}
}

// TestLoadParsesRules tests that rules.yaml, models.yaml and gen.yaml load.
//
// Why this test is important:
//   - Every target reads the typed model; a dropped field silently renders wrong.
//
// What it tests:
//   - Targets, model roles, and every rule field (including the guard block) parse.
func TestLoadParsesRules(t *testing.T) {
	root := t.TempDir()
	writeFile(t, root, ".claude/src/gen.yaml", "targets: [rules]\n")
	writeFile(t, root, ".claude/src/models.yaml", "review: {model: claude-fable-5-1, effort: xhigh}\n")
	writeFile(t, root, ".claude/src/rules.yaml", `- id: no-verify
  statement: Do not bypass hooks.
  summary: No hook bypass.
  category: git
  severity: must_fix
  enforce: hook
  hook: bash-guard
  paths: ["**/*.go"]
  targets: [claude-md]
  guard:
    argv0: git
    subcommands: [commit]
    flags: {all: [--no-verify], commit: [-n]}
    env: {LEFTHOOK: ["0"]}
    reason: hooks are gates
`)
	m, err := model.Load(root)
	if err != nil {
		t.Fatalf("Load: %v", err)
	}
	if got := strings.Join(m.Gen.Targets, ","); got != "rules" {
		t.Fatalf("targets = %q", got)
	}
	if r := m.Models["review"]; r.Model != "claude-fable-5-1" || r.Effort != "xhigh" {
		t.Fatalf("review role = %+v", r)
	}
	if len(m.Rules) != 1 {
		t.Fatalf("rules = %d, want 1", len(m.Rules))
	}
	r := m.Rules[0]
	if r.ID != "no-verify" || r.Enforce != "hook" || r.Hook != "bash-guard" || r.Summary != "No hook bypass." {
		t.Fatalf("rule = %+v", r)
	}
	if r.Guard == nil || r.Guard.Flags["commit"][0] != "-n" || r.Guard.Env["LEFTHOOK"][0] != "0" {
		t.Fatalf("guard = %+v", r.Guard)
	}
}

// TestLoadMalformedYamlNamesFile tests the error for unparseable YAML.
//
// Why this test is important:
//   - A YAML typo must point at the file to fix, not fail anonymously.
//
// What it tests:
//   - Load returns an invalid_model error whose message names rules.yaml.
func TestLoadMalformedYamlNamesFile(t *testing.T) {
	root := t.TempDir()
	writeFile(t, root, ".claude/src/rules.yaml", "- id: [unclosed\n")
	_, err := model.Load(root)
	if err == nil {
		t.Fatal("Load succeeded on malformed YAML")
	}
	if !strings.Contains(err.Error(), "rules.yaml") || !strings.Contains(err.Error(), "invalid_model") {
		t.Fatalf("error = %v", err)
	}
}

// TestLoadRejectsUnknownSkillKey tests strict decoding of source YAML.
//
// Why this test is important:
//   - A stale or misspelled key (next:, a typo of when_to_use) used to be
//     dropped silently, so the author's intent never reached the output.
//
// What it tests:
//   - A skill with `next: [x]` fails Load with invalid_model naming the file.
func TestLoadRejectsUnknownSkillKey(t *testing.T) {
	root := t.TempDir()
	writeFile(t, root, ".claude/src/skills/fix.yaml", "name: fix\nnext: [x]\n")
	_, err := model.Load(root)
	if err == nil || !strings.Contains(err.Error(), "fix.yaml") || !strings.Contains(err.Error(), "invalid_model") {
		t.Fatalf("error = %v", err)
	}
}
