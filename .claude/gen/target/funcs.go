package target

import (
	"fmt"
	"strings"
	"text/template"

	"claudegen/model"
)

// FuncMap returns the template functions every target's templates share,
// bound to m:
//
//	rule ID        the rule's statement
//	summary ID     the rule's condensed summary, for mirrors
//	lenses GROUP   rules listing GROUP-lenses, as bullets grouped by category
//	model ROLE     "model (effort)" or "model" for a models.yaml role
//	indent N TEXT  TEXT with N spaces before every line (use in a pipeline)
//	mirror NAME    the Cursor rule NAME's body for Codex: frontmatter and trailing newlines stripped
func FuncMap(m *model.Model) template.FuncMap {
	return template.FuncMap{
		"rule":    func(id string) (string, error) { return ruleStatement(m, id) },
		"summary": func(id string) (string, error) { return ruleSummary(m, id) },
		"lenses":  func(group string) string { return lensList(m, group+"-lenses") },
		"model":   func(role string) (string, error) { return roleModel(m, role) },
		"indent":  indent,
		"mirror":  func(name string) (string, error) { return mirrorBody(m, name) },
	}
}

// ruleStatement returns the statement of the rule with id.
func ruleStatement(m *model.Model, id string) (string, error) {
	for _, r := range m.Rules {
		if r.ID == id {
			return r.Statement, nil
		}
	}
	return "", model.New(model.CodeInvalidModel, fmt.Sprintf("unknown rule %q", id))
}

// ruleSummary returns the summary of the rule with id. An unknown id and a
// rule without a summary are distinct errors, since a mirror would otherwise
// render an empty sentence.
func ruleSummary(m *model.Model, id string) (string, error) {
	for _, r := range m.Rules {
		if r.ID != id {
			continue
		}
		if r.Summary == "" {
			return "", model.New(model.CodeInvalidModel, fmt.Sprintf("rule %q has no summary", id))
		}
		return r.Summary, nil
	}
	return "", model.New(model.CodeInvalidModel, fmt.Sprintf("unknown rule %q", id))
}

// rulesFor returns the rules whose targets include target, in catalog order.
func rulesFor(m *model.Model, target string) []model.Rule {
	var out []model.Rule
	for _, r := range m.Rules {
		for _, t := range r.Targets {
			if t == target {
				out = append(out, r)
				break
			}
		}
	}
	return out
}

// lensList renders the statements for target grouped under their category,
// categories in order of first appearance; a one-statement category renders
// on one line.
func lensList(m *model.Model, target string) string {
	var order []string
	groups := map[string][]string{}
	for _, r := range rulesFor(m, target) {
		if _, seen := groups[r.Category]; !seen {
			order = append(order, r.Category)
		}
		groups[r.Category] = append(groups[r.Category], r.Statement)
	}
	var lines []string
	for _, c := range order {
		if len(groups[c]) == 1 {
			lines = append(lines, "- **"+c+":** "+groups[c][0])
			continue
		}
		lines = append(lines, "- **"+c+":**")
		for _, s := range groups[c] {
			lines = append(lines, "  - "+s)
		}
	}
	return strings.Join(lines, "\n")
}

// roleModel formats a models.yaml role.
func roleModel(m *model.Model, role string) (string, error) {
	r, ok := m.Models[role]
	if !ok {
		return "", model.New(model.CodeInvalidModel, fmt.Sprintf("unknown model role %q", role))
	}
	if r.Effort == "" {
		return r.Model, nil
	}
	return r.Model + " (" + r.Effort + ")", nil
}

// indent prefixes every line of text with n spaces.
func indent(n int, text string) string {
	pad := strings.Repeat(" ", n)
	return pad + strings.ReplaceAll(text, "\n", "\n"+pad)
}

// mirrorBody renders the Cursor template name for ReaderCodex and strips its frontmatter and
// trailing newlines, so other targets compose it without a second copy.
func mirrorBody(m *model.Model, name string) (string, error) {
	body, err := execFile(m, srcPath(m, "mirrors/cursor/"+name+".mdc.tmpl"), MirrorData{Model: m, Reader: ReaderCodex})
	if err != nil {
		return "", err
	}
	return strings.TrimRight(string(stripFrontmatter(body)), "\n"), nil
}
