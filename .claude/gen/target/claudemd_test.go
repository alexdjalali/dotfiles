package target_test

import (
	"os"
	"strings"
	"testing"

	"claudegen/model"
	"claudegen/target"
)

// renderLoaded loads the model at root and renders kind.
func renderLoaded(t *testing.T, kind, root string) []target.File {
	t.Helper()
	m, err := model.Load(root)
	if err != nil {
		t.Fatal(err)
	}
	ts, err := target.Default().Select([]string{kind})
	if err != nil {
		t.Fatal(err)
	}
	files, err := ts[0].Render(m)
	if err != nil {
		t.Fatal(err)
	}
	return files
}

// TestClaudeMdGolden tests the claude-md target against its golden file.
//
// Why this test is important:
//   - CLAUDE.md loads into every session; it must render exactly.
//
// What it tests:
//   - src/claude.md.tmpl renders to .claude/CLAUDE.md with the marker on
//     line 1 and {{model}} resolved from models.yaml.
func TestClaudeMdGolden(t *testing.T) {
	files := renderLoaded(t, "claude-md", "../testdata/claudemd")
	want, err := os.ReadFile("../testdata/claudemd/golden.md")
	if err != nil {
		t.Fatal(err)
	}
	if len(files) != 1 || files[0].Path != ".claude/CLAUDE.md" || string(files[0].Data) != string(want) {
		t.Fatalf("files = %+v", files)
	}
}

// TestClaudeMdKeepsImportLine tests the @import line survives rendering.
//
// Why this test is important:
//   - CLAUDE.md pulls in RTK.md with @RTK.md; a template that mangled it
//     would drop those instructions.
//
// What it tests:
//   - The rendered file's last line is exactly @RTK.md.
func TestClaudeMdKeepsImportLine(t *testing.T) {
	files := renderLoaded(t, "claude-md", "../testdata/claudemd")
	lines := strings.Split(strings.TrimRight(string(files[0].Data), "\n"), "\n")
	if lines[len(lines)-1] != "@RTK.md" {
		t.Fatalf("last line = %q", lines[len(lines)-1])
	}
}
