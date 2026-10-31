package target_test

import (
	"bytes"
	"strings"
	"testing"
	"text/template"

	"claudegen/model"
	"claudegen/target"
)

// catalog is a model with three rules across two targets and two roles.
func catalog() *model.Model {
	return &model.Model{
		Models: map[string]model.ModelRole{
			"review":   {Model: "claude-fable-5-1", Effort: "xhigh"},
			"diagnose": {Model: "opus"},
		},
		Rules: []model.Rule{
			{ID: "b-rule", Statement: "B first.", Category: "Quality", Targets: []string{"claude-md", "review-lenses"}},
			{ID: "a-rule", Statement: "A second.", Category: "Correctness", Targets: []string{"claude-md", "review-lenses"}},
			{ID: "c-rule", Statement: "C elsewhere.", Category: "Quality", Targets: []string{"rules/testing", "review-lenses"}},
		},
	}
}

// exec runs a template text with the catalog's FuncMap.
func exec(t *testing.T, text string) (string, error) {
	t.Helper()
	tmpl, err := template.New("t").Funcs(target.FuncMap(catalog())).Parse(text)
	if err != nil {
		return "", err
	}
	var buf bytes.Buffer
	err = tmpl.Execute(&buf, nil)
	return buf.String(), err
}

// TestRuleReturnsStatement tests the rule function.
//
// Why this test is important:
//   - {{rule}} is how a statement is written once and reused.
//
// What it tests:
//   - {{rule "a-rule"}} renders exactly that rule's statement.
func TestRuleReturnsStatement(t *testing.T) {
	got, err := exec(t, `x {{rule "a-rule"}} y`)
	if err != nil || got != "x A second. y" {
		t.Fatalf("got %q, err %v", got, err)
	}
}

// TestRuleUnknownIDErrors tests the failure on a typo.
//
// Why this test is important:
//   - A misspelled id must fail the build, not render an empty sentence.
//
// What it tests:
//   - {{rule "nope"}} fails naming the id.
func TestRuleUnknownIDErrors(t *testing.T) {
	_, err := exec(t, `{{rule "nope"}}`)
	if err == nil || !strings.Contains(err.Error(), `unknown rule "nope"`) {
		t.Fatalf("err = %v", err)
	}
}

// TestLensesGroupsByCategory tests the review-lens list.
//
// Why this test is important:
//   - review-diff's checklist is rendered from the catalog grouped by category.
//
// What it tests:
//   - {{lenses "review"}} groups Quality (b, c) before Correctness (a), by
//     first appearance; a one-item group renders on one line.
func TestLensesGroupsByCategory(t *testing.T) {
	got, err := exec(t, `{{lenses "review"}}`)
	want := "- **Quality:**\n  - B first.\n  - C elsewhere.\n- **Correctness:** A second."
	if err != nil || got != want {
		t.Fatalf("got %q\nwant %q, err %v", got, want, err)
	}
}

// TestModelFormatsRole tests the model function.
//
// Why this test is important:
//   - CLAUDE.md's Models line must match the skills' pins.
//
// What it tests:
//   - A role with effort renders "model (effort)", without renders "model",
//     and an unknown role fails.
func TestModelFormatsRole(t *testing.T) {
	got, err := exec(t, `{{model "review"}}/{{model "diagnose"}}`)
	if err != nil || got != "claude-fable-5-1 (xhigh)/opus" {
		t.Fatalf("got %q, err %v", got, err)
	}
	if _, err := exec(t, `{{model "nope"}}`); err == nil {
		t.Fatal("unknown role rendered")
	}
}

// TestReviewLensesCoverLegacyList tests the migrated review checklist.
//
// Why this test is important:
//   - review-diff's lenses moved from hand-written prose into the catalog;
//     a lens lost in the move silently narrows every review.
//
// What it tests:
//   - The repository's catalog renders, through {{lenses "review"}} and
//     {{lenses "audit"}}, every lens and category the hand-written skills had.
func TestReviewLensesCoverLegacyList(t *testing.T) {
	m, err := model.Load("../../..")
	if err != nil {
		t.Fatal(err)
	}
	run := func(text string) string {
		tmpl := template.Must(template.New("t").Funcs(target.FuncMap(m)).Parse(text))
		var buf bytes.Buffer
		if err := tmpl.Execute(&buf, nil); err != nil {
			t.Fatal(err)
		}
		return buf.String()
	}
	review, audit := run(`{{lenses "review"}}`), run(`{{lenses "audit"}}`)
	for _, kw := range []string{
		"edge cases", "error paths", "concurrency", "resource lifecycle", "contracts", "security",
		"performance", "dead code", "consistency and DRY", "tests (", "standards", "design",
		"codegen", "config", "resilience", "errors", "observability", "docs", "Correctness", "Quality",
	} {
		if !strings.Contains(review, kw) {
			t.Errorf("review lenses lost %q", kw)
		}
	}
	for _, kw := range []string{
		"DRY", "coupling", "complexity", "anti-patterns", "dead code", "convention drift",
		"test gaps", "One-Idea drift", "codegen gaps", "operability",
	} {
		if !strings.Contains(audit, "**"+kw+":**") {
			t.Errorf("audit categories lost %q", kw)
		}
	}
}

// TestIndentNestsEveryLine tests the indent function.
//
// Why this test is important:
//   - A list rendered inside a numbered step must be indented on every line,
//     or Markdown ends the step.
//
// What it tests:
//   - {{lenses "review" | indent 3}} prefixes each line with three spaces.
func TestIndentNestsEveryLine(t *testing.T) {
	got, err := exec(t, `{{lenses "review" | indent 3}}`)
	want := "   - **Quality:**\n     - B first.\n     - C elsewhere.\n   - **Correctness:** A second."
	if err != nil || got != want {
		t.Fatalf("got %q, err %v", got, err)
	}
}
