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

// Rules are the always-loaded instructions; a rendering slip changes every session.
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

// Claude Code reads frontmatter only when --- is line 1; a marker above it would drop every frontmatter field.
func TestMarkerInsideFrontmatter(t *testing.T) {
	got := string(target.WithMarker([]byte("---\nname: x\n---\nbody\n")))
	if !strings.HasPrefix(got, "---\n# "+target.Marker+"\nname: x\n") {
		t.Fatalf("got %q", got)
	}
}

// The edit guard finds the marker in the first lines; it must be there.
func TestMarkerBeforePlainBody(t *testing.T) {
	got := string(target.WithMarker([]byte("## Title\n")))
	if got != "<!-- "+target.Marker+" -->\n## Title\n" {
		t.Fatalf("got %q", got)
	}
}

// With dozens of templates, an anonymous parse error is unfixable.
func TestTemplateErrorNamesFile(t *testing.T) {
	_, err := renderKind(t, "rules", "../testdata/badtmpl")
	if err == nil || !strings.Contains(err.Error(), "broken.md.tmpl") || !strings.Contains(err.Error(), "invalid_model") {
		t.Fatalf("err = %v", err)
	}
}
