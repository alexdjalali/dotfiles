package model_test

import (
	"strings"
	"testing"

	"claudegen/model"
)

// validRule returns a rule that passes validation, for tests to break one field.
func validRule(id string) model.Rule {
	return model.Rule{
		ID:        id,
		Statement: "State it once.",
		Category:  "git",
		Severity:  "must_fix",
		Enforce:   "prose",
		Targets:   []string{"claude-md"},
	}
}

// fields returns "path:field" for each error, for compact assertions.
func fields(errs []model.Error) []string {
	out := make([]string, 0, len(errs))
	for _, e := range errs {
		out = append(out, e.Path+":"+e.Field)
	}
	return out
}

// hasField reports whether errs holds an error at path and field.
func hasField(errs []model.Error, path, field string) bool {
	for _, e := range errs {
		if e.Path == path && e.Field == field {
			return true
		}
	}
	return false
}

// TestValidateValidModelHasNoErrors tests the clean path.
//
// Why this test is important:
//   - A validator that always reports something blocks every render.
//
// What it tests:
//   - A model with one valid rule and a valid role yields no errors.
func TestValidateValidModelHasNoErrors(t *testing.T) {
	m := &model.Model{
		Models: map[string]model.ModelRole{"review": {Model: "opus", Effort: "xhigh"}},
		Rules:  []model.Rule{validRule("a")},
	}
	if errs := model.Validate(m); len(errs) != 0 {
		t.Fatalf("errors = %v", errs)
	}
}

// TestValidateAggregatesAllErrors tests that every violation is reported at once.
//
// Why this test is important:
//   - Fixing one error per run is slow; the user needs the full list.
//
// What it tests:
//   - Two broken fields in two rules both appear, each formatted path:field: message.
func TestValidateAggregatesAllErrors(t *testing.T) {
	a, b := validRule("a"), validRule("b")
	a.Severity = "fatal"
	b.Statement = ""
	errs := model.Validate(&model.Model{Rules: []model.Rule{a, b}})
	if !hasField(errs, "rules.yaml", "/0/severity") || !hasField(errs, "rules.yaml", "/1/statement") {
		t.Fatalf("errors = %v", fields(errs))
	}
	if got := errs[0].String(); !strings.HasPrefix(got, "rules.yaml:/") {
		t.Fatalf("String() = %q", got)
	}
}

// TestValidateHookNeedsHookKind tests that a hook-enforced rule names its hook.
//
// Why this test is important:
//   - The guard-table target selects rows by hook kind; a missing kind drops the row.
//
// What it tests:
//   - enforce: hook without hook reports /0/hook.
func TestValidateHookNeedsHookKind(t *testing.T) {
	r := validRule("a")
	r.Enforce = "hook"
	errs := model.Validate(&model.Model{Rules: []model.Rule{r}})
	if !hasField(errs, "rules.yaml", "/0/hook") {
		t.Fatalf("errors = %v", fields(errs))
	}
}

// TestValidateBashGuardNeedsGuardBlock tests that a bash-guard rule carries its row.
//
// Why this test is important:
//   - Without the guard block the Bash guard silently enforces nothing.
//
// What it tests:
//   - hook: bash-guard without guard reports /0/guard; edit-guard needs none.
func TestValidateBashGuardNeedsGuardBlock(t *testing.T) {
	bash, edit := validRule("a"), validRule("b")
	bash.Enforce, bash.Hook = "hook", "bash-guard"
	edit.Enforce, edit.Hook = "hook", "edit-guard"
	errs := model.Validate(&model.Model{Rules: []model.Rule{bash, edit}})
	if !hasField(errs, "rules.yaml", "/0/guard") {
		t.Fatalf("errors = %v", fields(errs))
	}
	if hasField(errs, "rules.yaml", "/1/guard") {
		t.Fatalf("edit-guard rule wrongly needs a guard block: %v", fields(errs))
	}
}

// TestValidateDuplicateRuleID tests rule id uniqueness.
//
// Why this test is important:
//   - {{rule "id"}} must resolve to exactly one statement.
//
// What it tests:
//   - The second rule with a repeated id reports /1/id.
func TestValidateDuplicateRuleID(t *testing.T) {
	errs := model.Validate(&model.Model{Rules: []model.Rule{validRule("a"), validRule("a")}})
	if !hasField(errs, "rules.yaml", "/1/id") || hasField(errs, "rules.yaml", "/0/id") {
		t.Fatalf("errors = %v", fields(errs))
	}
}

// TestValidateBadSeverity tests the severity enum and the effort enum.
//
// Why this test is important:
//   - Review tiers and skill effort are closed sets; a typo must not render.
//
// What it tests:
//   - severity "major" reports /0/severity; effort "huge" reports /review/effort.
func TestValidateBadSeverity(t *testing.T) {
	r := validRule("a")
	r.Severity = "major"
	m := &model.Model{
		Models: map[string]model.ModelRole{"review": {Model: "opus", Effort: "huge"}},
		Rules:  []model.Rule{r},
	}
	errs := model.Validate(m)
	if !hasField(errs, "rules.yaml", "/0/severity") || !hasField(errs, "models.yaml", "/review/effort") {
		t.Fatalf("errors = %v", fields(errs))
	}
}

// TestEmphasisRejectedForHookRule tests the emphasis constraint.
//
// Why this test is important:
//   - A rule a hook enforces needs no ⛔/NEVER/MUST; emphasis makes current
//     models over-apply it.
//
// What it tests:
//   - A hook-enforced statement with ⛔, and a lint-enforced one with NEVER,
//     each report /i/statement naming the rule.
func TestEmphasisRejectedForHookRule(t *testing.T) {
	hook, lint := validRule("hooked"), validRule("linted")
	hook.Enforce, hook.Hook, hook.Statement = "hook", "edit-guard", "⛔ Do not edit generated files."
	lint.Enforce, lint.Statement = "lint", "NEVER use fmt.Errorf."
	errs := model.Validate(&model.Model{Rules: []model.Rule{hook, lint}})
	if !hasField(errs, "rules.yaml", "/0/statement") || !hasField(errs, "rules.yaml", "/1/statement") {
		t.Fatalf("errors = %v", fields(errs))
	}
	if !strings.Contains(errs[0].Message, `"hooked"`) {
		t.Fatalf("message = %q", errs[0].Message)
	}
}

// TestEmphasisAllowedForProseRule tests that unenforced rules keep emphasis.
//
// Why this test is important:
//   - Without a machine check, emphasis may still be the author's choice.
//
// What it tests:
//   - A prose rule with MUST validates cleanly.
func TestEmphasisAllowedForProseRule(t *testing.T) {
	r := validRule("a")
	r.Statement = "You MUST ask first."
	if errs := model.Validate(&model.Model{Rules: []model.Rule{r}}); len(errs) != 0 {
		t.Fatalf("errors = %v", fields(errs))
	}
}

// TestMustInsideWordIgnored tests whole-word matching.
//
// Why this test is important:
//   - "MUSTACHE" or "NEVERTHELESS" are not emphasis.
//
// What it tests:
//   - A hook rule whose statement contains MUSTACHE and NEVERTHELESS validates.
func TestMustInsideWordIgnored(t *testing.T) {
	r := validRule("a")
	r.Enforce, r.Hook, r.Statement = "hook", "edit-guard", "MUSTACHE templates, NEVERTHELESS fine."
	if errs := model.Validate(&model.Model{Rules: []model.Rule{r}}); len(errs) != 0 {
		t.Fatalf("errors = %v", fields(errs))
	}
}
