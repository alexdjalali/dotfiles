package target_test

import (
	"bytes"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"claudegen/model"
	"claudegen/target"
)

// renderKind renders the Default registry's kind against a model rooted at root.
func renderKind(t *testing.T, kind, root string) ([]target.File, error) {
	t.Helper()
	ts, err := target.Default().Select([]string{kind})
	if err != nil {
		t.Fatal(err)
	}
	return ts[0].Render(&model.Model{Root: root})
}

// TestRulesGolden tests the rules target against committed expected output.
//
// Why this test is important:
//   - Rules are the always-loaded instructions; a rendering slip changes
//     every session.
//
// What it tests:
//   - Each src/rules/*.md.tmpl renders to .claude/rules/<name>.md exactly as
//     the golden file, marker included.
func TestRulesGolden(t *testing.T) {
	files, err := renderKind(t, "rules", "../testdata/rules/src")
	if err != nil {
		t.Fatal(err)
	}
	if len(files) != 2 {
		t.Fatalf("rendered %d files, want 2", len(files))
	}
	for _, f := range files {
		want, err := os.ReadFile(filepath.Join("../testdata/rules/golden", f.Path))
		if err != nil {
			t.Fatalf("golden for %s: %v", f.Path, err)
		}
		if !bytes.Equal(f.Data, want) {
			t.Errorf("%s:\n got %q\nwant %q", f.Path, f.Data, want)
		}
	}
}

// TestMarkerInsideFrontmatter tests marker placement for files with frontmatter.
//
// Why this test is important:
//   - Claude Code reads frontmatter only when --- is line 1; a marker above it
//     would drop every frontmatter field.
//
// What it tests:
//   - WithMarker keeps --- first and puts the marker as a YAML comment on line 2.
func TestMarkerInsideFrontmatter(t *testing.T) {
	got := string(target.WithMarker([]byte("---\nname: x\n---\nbody\n")))
	if !strings.HasPrefix(got, "---\n# "+target.Marker+"\nname: x\n") {
		t.Fatalf("got %q", got)
	}
}

// TestMarkerBeforePlainBody tests marker placement for files without frontmatter.
//
// Why this test is important:
//   - The edit guard finds the marker in the first lines; it must be there.
//
// What it tests:
//   - WithMarker prepends an HTML comment line and keeps the body unchanged.
func TestMarkerBeforePlainBody(t *testing.T) {
	got := string(target.WithMarker([]byte("## Title\n")))
	if got != "<!-- "+target.Marker+" -->\n## Title\n" {
		t.Fatalf("got %q", got)
	}
}

// TestTemplateErrorNamesFile tests the error for a broken template.
//
// Why this test is important:
//   - With dozens of templates, an anonymous parse error is unfixable.
//
// What it tests:
//   - Rendering a malformed template fails with invalid_model naming the file.
func TestTemplateErrorNamesFile(t *testing.T) {
	_, err := renderKind(t, "rules", "../testdata/badtmpl")
	if err == nil || !strings.Contains(err.Error(), "broken.md.tmpl") || !strings.Contains(err.Error(), "invalid_model") {
		t.Fatalf("err = %v", err)
	}
}
