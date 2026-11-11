package target_test

import (
	"os"
	"testing"
)

// TestProbityGolden tests the probity target against its golden file.
//
// Why this test is important:
//   - A project copies the rendered probity.config.ts; a wrong row or a
//     broken string literal reaches Probity's validator as its instructions.
//
// What it tests:
//   - The file lands at .claude/templates/probity/probity.config.ts with the
//     marker as a // comment on line 1.
//   - Only rules targeting probity appear, in catalog order, as an escaped
//     TypeScript string array; a rule without the probity target is absent.
func TestProbityGolden(t *testing.T) {
	files := renderLoaded(t, "probity", "../testdata/probity")
	want, err := os.ReadFile("../testdata/probity/golden.ts")
	if err != nil {
		t.Fatal(err)
	}
	if len(files) != 1 || files[0].Path != ".claude/templates/probity/probity.config.ts" {
		t.Fatalf("files = %+v", files)
	}
	if string(files[0].Data) != string(want) {
		t.Fatalf("got:\n%s\nwant:\n%s", files[0].Data, want)
	}
}
