package writer_test

import (
	"os"
	"path/filepath"
	"sort"
	"strings"
	"testing"

	"claudegen/target"
	"claudegen/writer"
)

// marked is file content carrying the generated marker.
const marked = "<!-- " + target.Marker + " -->\nbody\n"

// put writes content to rel under root.
func put(t *testing.T, root, rel, content string) {
	t.Helper()
	p := filepath.Join(root, rel)
	if err := os.MkdirAll(filepath.Dir(p), 0o755); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(p, []byte(content), 0o644); err != nil {
		t.Fatal(err)
	}
}

// read returns the content of rel under root, or "<missing>".
func read(t *testing.T, root, rel string) string {
	t.Helper()
	b, err := os.ReadFile(filepath.Join(root, rel))
	if err != nil {
		return "<missing>"
	}
	return string(b)
}

// render is the set of files a run produced: two rules.
var render = []target.File{
	{Path: "rules/a.md", Data: []byte(marked)},
	{Path: "rules/b.md", Data: []byte(marked)},
}

// --check runs in just lint; a false drift fails every commit.
func TestCheckCleanTreeIsEmpty(t *testing.T) {
	root := t.TempDir()
	if err := writer.Write(root, render, []string{"rules"}); err != nil {
		t.Fatal(err)
	}
	if d := writer.Check(root, render, []string{"rules"}); len(d) != 0 {
		t.Fatalf("drift = %v", d)
	}
}

// A hand edit, a deleted output and a stale output are the three ways generated files go wrong; each must fail the check.
func TestCheckReportsDiffersMissingOrphan(t *testing.T) {
	root := t.TempDir()
	put(t, root, "rules/a.md", "hand edited\n")
	put(t, root, "rules/c.md", marked)
	put(t, root, "rules/d.md", "hand-written rule\n")
	got := []string{}
	for _, d := range writer.Check(root, render, []string{"rules"}) {
		got = append(got, d.Kind+" "+d.Path)
	}
	sort.Strings(got)
	want := "differs rules/a.md,missing rules/b.md,orphan rules/c.md"
	if strings.Join(got, ",") != want {
		t.Fatalf("drift = %v, want %s", got, want)
	}
}

// Removing a template must remove its output, but hand-written files in the same directory must survive migration.
func TestWriteDeletesMarkedOrphanOnly(t *testing.T) {
	root := t.TempDir()
	put(t, root, "rules/c.md", marked)
	put(t, root, "rules/d.md", "hand-written rule\n")
	if err := writer.Write(root, render, []string{"rules"}); err != nil {
		t.Fatal(err)
	}
	if got := read(t, root, "rules/c.md"); got != "<missing>" {
		t.Fatalf("orphan survived: %q", got)
	}
	if got := read(t, root, "rules/d.md"); got != "hand-written rule\n" {
		t.Fatalf("unmarked file changed: %q", got)
	}
}

// Claude Code may read a rule mid-write; a partial file loses instructions.
func TestWriteIsAtomicOnRename(t *testing.T) {
	root := t.TempDir()
	put(t, root, "rules/a.md", strings.Repeat("old content\n", 50))
	if err := writer.Write(root, render, []string{"rules"}); err != nil {
		t.Fatal(err)
	}
	if got := read(t, root, "rules/a.md"); got != marked {
		t.Fatalf("a.md = %q", got)
	}
	entries, _ := os.ReadDir(filepath.Join(root, "rules"))
	if len(entries) != 2 {
		t.Fatalf("rules/ holds %d entries, want 2 (temp file left?)", len(entries))
	}
}
