package target_test

import (
	"os"
	"path/filepath"
	"reflect"
	"strings"
	"testing"

	"gopkg.in/yaml.v3"
)

// splitSkill returns a SKILL.md's frontmatter (parsed) and its body.
func splitSkill(t *testing.T, data string) (map[string]any, string) {
	t.Helper()
	rest, ok := strings.CutPrefix(data, "---\n")
	if !ok {
		t.Fatalf("no frontmatter: %.40q", data)
	}
	front, body, ok := strings.Cut(rest, "\n---\n")
	if !ok {
		t.Fatalf("unterminated frontmatter: %.40q", data)
	}
	fm := map[string]any{}
	if err := yaml.Unmarshal([]byte(front), &fm); err != nil {
		t.Fatal(err)
	}
	return fm, body
}

// TestSkillsPreserveFrontmatter tests the migration of the 14 hand-written skills.
//
// Why this test is important:
//   - Frontmatter drives model, effort, context and invocation; descriptions
//     drive triggering. Moving the skills into the generator must not change
//     either, and bodies change only where the catalog now renders the lists.
//
// What it tests:
//   - For every skill in testdata/skills-legacy, the repository's skills
//     target renders frontmatter with equal key/value pairs, and a body equal
//     to the legacy body except in review-diff and audit (lens lists) and the
//     skills that gained injected lines.
func TestSkillsPreserveFrontmatter(t *testing.T) {
	files := renderLoaded(t, "skills", "../../..")
	rendered := map[string]string{}
	for _, f := range files {
		rendered[filepath.Base(filepath.Dir(f.Path))] = string(f.Data)
	}
	legacy, err := filepath.Glob("../testdata/skills-legacy/*/SKILL.md")
	if err != nil || len(legacy) != 14 {
		t.Fatalf("legacy skills = %d, err %v", len(legacy), err)
	}
	changedBody := map[string]bool{"review-diff": true, "audit": true, "spec": true, "learn": true}
	for _, p := range legacy {
		name := filepath.Base(filepath.Dir(p))
		data, err := os.ReadFile(p)
		if err != nil {
			t.Fatal(err)
		}
		gotFM, gotBody := splitSkill(t, rendered[name])
		wantFM, wantBody := splitSkill(t, string(data))
		if !reflect.DeepEqual(gotFM, wantFM) {
			t.Errorf("%s frontmatter:\n got %v\nwant %v", name, gotFM, wantFM)
		}
		if !changedBody[name] && gotBody != wantBody {
			t.Errorf("%s body changed", name)
		}
	}
}
