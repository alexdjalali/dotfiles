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

// TestRulesOrderedByCatalog tests the rules list function.
//
// Why this test is important:
//   - Rule order in rules.yaml is the authored reading order.
//
// What it tests:
//   - {{rules "claude-md"}} renders b-rule then a-rule as bullets, omitting c-rule.
func TestRulesOrderedByCatalog(t *testing.T) {
	got, err := exec(t, `{{rules "claude-md"}}`)
	if err != nil || got != "- B first.\n- A second." {
		t.Fatalf("got %q, err %v", got, err)
	}
}

// TestLensesGroupsByCategory tests the review-lens list.
//
// Why this test is important:
//   - review-diff's checklist is rendered from the catalog grouped by category.
//
// What it tests:
//   - {{lenses "review"}} groups Quality (b, c) before Correctness (a), by first appearance.
func TestLensesGroupsByCategory(t *testing.T) {
	got, err := exec(t, `{{lenses "review"}}`)
	want := "- **Quality:**\n  - B first.\n  - C elsewhere.\n- **Correctness:**\n  - A second."
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
