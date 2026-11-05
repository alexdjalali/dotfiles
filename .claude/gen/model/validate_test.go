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

// A validator that always reports something blocks every render.
func TestValidateValidModelHasNoErrors(t *testing.T) {
	m := &model.Model{
		Models: map[string]model.ModelRole{"review": {Model: "opus", Effort: "xhigh"}},
		Rules:  []model.Rule{validRule("a")},
	}
	if errs := model.Validate(m); len(errs) != 0 {
		t.Fatalf("errors = %v", errs)
	}
}

// Fixing one error per run is slow; the user needs the full list.
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

// The guard-table target selects rows by hook kind; a missing kind drops the row.
func TestValidateHookNeedsHookKind(t *testing.T) {
	r := validRule("a")
	r.Enforce = "hook"
	errs := model.Validate(&model.Model{Rules: []model.Rule{r}})
	if !hasField(errs, "rules.yaml", "/0/hook") {
		t.Fatalf("errors = %v", fields(errs))
	}
}

// Without the guard block the Bash guard silently enforces nothing.
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

// {{rule "id"}} must resolve to exactly one statement.
func TestValidateDuplicateRuleID(t *testing.T) {
	errs := model.Validate(&model.Model{Rules: []model.Rule{validRule("a"), validRule("a")}})
	if !hasField(errs, "rules.yaml", "/1/id") || hasField(errs, "rules.yaml", "/0/id") {
		t.Fatalf("errors = %v", fields(errs))
	}
}

// Review tiers and skill effort are closed sets; a typo must not render.
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

// A rule a hook enforces needs no ⛔/NEVER/MUST; emphasis makes current models over-apply it.
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

// Without a machine check, emphasis may still be the author's choice.
func TestEmphasisAllowedForProseRule(t *testing.T) {
	r := validRule("a")
	r.Statement = "You MUST ask first."
	if errs := model.Validate(&model.Model{Rules: []model.Rule{r}}); len(errs) != 0 {
		t.Fatalf("errors = %v", fields(errs))
	}
}

// "MUSTACHE" or "NEVERTHELESS" are not emphasis.
func TestMustInsideWordIgnored(t *testing.T) {
	r := validRule("a")
	r.Enforce, r.Hook, r.Statement = "hook", "edit-guard", "MUSTACHE templates, NEVERTHELESS fine."
	if errs := model.Validate(&model.Model{Rules: []model.Rule{r}}); len(errs) != 0 {
		t.Fatalf("errors = %v", fields(errs))
	}
}

// validSkill returns a skill that passes validation.
func validSkill(name string) model.Skill {
	return model.Skill{Name: name, File: name, Description: "Does a thing. Use when asked.", Role: "review", HasTemplate: true}
}

// skillModel wraps skills in a model with the review role defined.
func skillModel(skills ...model.Skill) *model.Model {
	return &model.Model{
		Models: map[string]model.ModelRole{"review": {Model: "opus"}},
		Skills: skills,
	}
}

// Claude Code names a skill after its folder; a mismatched name field makes /name and the listing disagree.
func TestSkillNameMustMatchFile(t *testing.T) {
	s := validSkill("fix")
	s.Name = "fixx"
	if errs := model.Validate(skillModel(s)); !hasField(errs, "skills/fix.yaml", "/name") {
		t.Fatalf("errors = %v", fields(errs))
	}
}

// Text past the cap is cut from the listing, so trigger phrases there never reach the model.
func TestDescriptionBudget(t *testing.T) {
	over, at := validSkill("a"), validSkill("b")
	over.Description, over.WhenToUse = strings.Repeat("x", 1000), strings.Repeat("y", 537)
	at.Description, at.WhenToUse = strings.Repeat("x", 1000), strings.Repeat("y", 536)
	errs := model.Validate(skillModel(over, at))
	if !hasField(errs, "skills/a.yaml", "/description") || hasField(errs, "skills/b.yaml", "/description") {
		t.Fatalf("errors = %v", fields(errs))
	}
}

// A skill's model pin comes from its role; a missing role renders no pin and the skill silently inherits the session model.
func TestRoleMustExist(t *testing.T) {
	none, bad := validSkill("a"), validSkill("b")
	none.Role, bad.Role = "", "nope"
	errs := model.Validate(skillModel(none, bad))
	if !hasField(errs, "skills/a.yaml", "/role") || !hasField(errs, "skills/b.yaml", "/role") {
		t.Fatalf("errors = %v", fields(errs))
	}
}

// Mirrors render a rule's summary; a missing one renders an empty sentence into Cursor and Kilocode.
func TestMirrorRuleNeedsSummary(t *testing.T) {
	mirrored, local := validRule("a"), validRule("b")
	mirrored.Targets = []string{"claude-md", "cursor/go"}
	errs := model.Validate(&model.Model{Rules: []model.Rule{mirrored, local}})
	if !hasField(errs, "rules.yaml", "/0/summary") || hasField(errs, "rules.yaml", "/1/summary") {
		t.Fatalf("errors = %v", fields(errs))
	}
	if want := `rule "a" targets cursor/go but has no summary`; !strings.Contains(errs[0].Message, want) {
		t.Fatalf("message = %q, want %q", errs[0].Message, want)
	}
}

// A missing skills/<name>.md.tmpl used to surface only at render, as an I/O error, after validation had passed.
func TestSkillTemplateMustExist(t *testing.T) {
	s := validSkill("fix")
	s.HasTemplate = false
	if errs := model.Validate(skillModel(s)); !hasField(errs, "skills/fix.md.tmpl", "") {
		t.Fatalf("errors = %v", fields(errs))
	}
}
