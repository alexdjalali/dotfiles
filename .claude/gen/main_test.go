package main

import (
	"bytes"
	"os"
	"path/filepath"
	"strings"
	"testing"
)

// tree builds a source tree with one rule template and gen.yaml enabling rules.
func tree(t *testing.T, rulesYAML string) string {
	t.Helper()
	root := t.TempDir()
	files := map[string]string{
		".claude/src/gen.yaml":        "targets: [rules]\n",
		".claude/src/rules/a.md.tmpl": "## A\n",
		".claude/src/rules.yaml":      rulesYAML,
	}
	for rel, content := range files {
		p := filepath.Join(root, rel)
		if err := os.MkdirAll(filepath.Dir(p), 0o755); err != nil {
			t.Fatal(err)
		}
		if err := os.WriteFile(p, []byte(content), 0o644); err != nil {
			t.Fatal(err)
		}
	}
	return root
}

// runCLI runs the CLI with args and returns its exit status and stderr.
func runCLI(args ...string) (int, string) {
	var out, errOut bytes.Buffer
	code := run(args, &out, &errOut)
	return code, errOut.String()
}

// TestRunWritesThenCheckClean tests the write-then-check round trip.
//
// Why this test is important:
//   - just lint runs --check right after a regenerate; they must agree.
//
// What it tests:
//   - A write exits 0 and creates .claude/rules/a.md; --check then exits 0.
func TestRunWritesThenCheckClean(t *testing.T) {
	root := tree(t, "[]\n")
	if code, errOut := runCLI("--root", root); code != 0 {
		t.Fatalf("write exit %d: %s", code, errOut)
	}
	if _, err := os.Stat(filepath.Join(root, ".claude/rules/a.md")); err != nil {
		t.Fatal(err)
	}
	if code, errOut := runCLI("--root", root, "--check"); code != 0 {
		t.Fatalf("check exit %d: %s", code, errOut)
	}
}

// TestRunCheckExits1OnDrift tests that a hand edit fails the check.
//
// Why this test is important:
//   - This is the gate that stops hand-edited generated files from landing.
//
// What it tests:
//   - After editing a.md, --check exits 1 and names the file.
func TestRunCheckExits1OnDrift(t *testing.T) {
	root := tree(t, "[]\n")
	runCLI("--root", root)
	if err := os.WriteFile(filepath.Join(root, ".claude/rules/a.md"), []byte("edited\n"), 0o644); err != nil {
		t.Fatal(err)
	}
	code, errOut := runCLI("--root", root, "--check")
	if code != 1 || !strings.Contains(errOut, ".claude/rules/a.md") {
		t.Fatalf("exit %d, stderr %q", code, errOut)
	}
}

// TestRunInvalidModelWritesNothing tests that validation precedes writing.
//
// Why this test is important:
//   - A half-applied render from a broken model leaves the config inconsistent.
//
// What it tests:
//   - A rule with a bad severity exits 1, prints the field, and writes no file.
func TestRunInvalidModelWritesNothing(t *testing.T) {
	root := tree(t, "- {id: a, statement: s, severity: fatal, enforce: prose, targets: [x]}\n")
	code, errOut := runCLI("--root", root)
	if code != 1 || !strings.Contains(errOut, "rules.yaml:/0/severity") {
		t.Fatalf("exit %d, stderr %q", code, errOut)
	}
	if _, err := os.Stat(filepath.Join(root, ".claude/rules/a.md")); err == nil {
		t.Fatal("a.md was written despite an invalid model")
	}
}

// TestRunBadFlagExits2 tests usage errors.
//
// Why this test is important:
//   - Scripts distinguish a usage mistake (2) from drift (1).
//
// What it tests:
//   - An unknown flag exits 2.
func TestRunBadFlagExits2(t *testing.T) {
	if code, _ := runCLI("--nope"); code != 2 {
		t.Fatalf("exit %d, want 2", code)
	}
}
