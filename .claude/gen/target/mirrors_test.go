package target_test

import (
	"bytes"
	"os"
	"path/filepath"
	"testing"

	"claudegen/target"
)

// TestCursorGolden tests the cursor target against its golden file.
//
// Why this test is important:
//   - Cursor loads these rules in place of CLAUDE.md; a catalog rule must
//     reach them as its condensed summary, frontmatter intact.
//
// What it tests:
//   - mirrors/cursor/alpha.mdc.tmpl renders to cursor/rules/alpha.mdc with
//     {{summary "no-verify"}} resolved and the marker inside the frontmatter.
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

// TestKilocodeMatchesLegacyTransform tests the Go port of the retired shell transform.
//
// Why this test is important:
//   - Kilocode reads the Cursor rules reshaped; the Go port must produce what
//     the retired shell transform did, and must not need the cursor target
//     selected to do it.
//
// What it tests:
//   - With only kilocode selected, the nine legacy Cursor rules render to the
//     nine legacy Kilocode files (typescript-react → typescript.md, .mdc
//     references rewritten) byte for byte once the line-1 marker is removed.
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

// TestAgentsMdGolden tests the agents-md target against its golden file.
//
// Why this test is important:
//   - Codex reads codex/AGENTS.md; it must carry the same condensed rules as
//     Cursor without a second hand-written copy.
//
// What it tests:
//   - agents.md.tmpl renders to codex/AGENTS.md with the marker on line 1 and
//     {{mirror "alpha"}} replaced by alpha's Cursor body, frontmatter and
//     trailing newline stripped, summaries resolved.
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
