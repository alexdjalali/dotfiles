package target_test

import (
	"bytes"
	"os"
	"path/filepath"
	"testing"

	"claudegen/target"
)

// Cursor loads these rules in place of CLAUDE.md; a catalog rule must reach them as its condensed summary, frontmatter intact.
func TestCursorGolden(t *testing.T) {
	files := renderLoaded(t, "cursor", "../testdata/cursor")
	want, err := os.ReadFile("../testdata/cursor/golden/alpha.mdc")
	if err != nil {
		t.Fatal(err)
	}
	if len(files) != 1 || files[0].Path != "cursor/rules/alpha.mdc" || string(files[0].Data) != string(want) {
		t.Fatalf("got %v", files)
	}
}

// Kilocode reads the Cursor rules reshaped; the Go port must produce what the retired shell transform did, and must not need the cursor target selected to do it.
func TestKilocodeMatchesLegacyTransform(t *testing.T) {
	files := renderLoaded(t, "kilocode", "../testdata/mirrors-legacy")
	if len(files) != 9 {
		t.Fatalf("rendered %d files, want 9", len(files))
	}
	marker := []byte("<!-- " + target.Marker + " -->\n")
	for _, f := range files {
		want, err := os.ReadFile(filepath.Join("../testdata/mirrors-legacy/kilocode-golden", filepath.Base(f.Path)))
		if err != nil {
			t.Fatal(err)
		}
		got, ok := bytes.CutPrefix(f.Data, marker)
		if filepath.Dir(f.Path) != "kilocode/rules" || !ok || !bytes.Equal(got, want) {
			t.Errorf("%s:\n got:\n%s\nwant:\n%s", f.Path, f.Data, want)
		}
	}
}

// Codex reads codex/AGENTS.md; it must carry the same condensed rules as Cursor without a second hand-written copy.
func TestAgentsMdGolden(t *testing.T) {
	files := renderLoaded(t, "agents-md", "../testdata/cursor")
	want, err := os.ReadFile("../testdata/cursor/golden/AGENTS.md")
	if err != nil {
		t.Fatal(err)
	}
	if len(files) != 1 || files[0].Path != "codex/AGENTS.md" || string(files[0].Data) != string(want) {
		t.Fatalf("got %q\nwant %q", files[0].Data, want)
	}
}
