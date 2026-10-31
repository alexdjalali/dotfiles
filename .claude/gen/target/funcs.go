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
//	rules TARGET   "- statement" lines for every rule listing TARGET, catalog order
//	lenses GROUP   rules listing GROUP-lenses, as bullets grouped by category
//	model ROLE     "model (effort)" or "model" for a models.yaml role
//	next SKILL     "- `/name` — summary" lines for the skill's next edges
//	indent N TEXT  TEXT with N spaces before every line (use in a pipeline)
func FuncMap(m *model.Model) template.FuncMap {
	return template.FuncMap{
		"rule":   func(id string) (string, error) { return ruleStatement(m, id) },
		"rules":  func(target string) string { return ruleList(m, target) },
		"lenses": func(group string) string { return lensList(m, group+"-lenses") },
		"model":  func(role string) (string, error) { return roleModel(m, role) },
		"next":   func(skill string) (string, error) { return nextList(m, skill) },
		"indent": indent,
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

// ruleList renders the statements for target as Markdown bullets.
func ruleList(m *model.Model, target string) string {
	rules := rulesFor(m, target)
	lines := make([]string, 0, len(rules))
	for _, r := range rules {
		lines = append(lines, "- "+r.Statement)
	}
	return strings.Join(lines, "\n")
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

// nextList renders a skill's next edges as "- `/name` — summary" lines.
func nextList(m *model.Model, name string) (string, error) {
	byName := map[string]model.Skill{}
	for _, sk := range m.Skills {
		byName[sk.Name] = sk
	}
	sk, ok := byName[name]
	if !ok {
		return "", model.New(model.CodeInvalidModel, fmt.Sprintf("unknown skill %q", name))
	}
	lines := make([]string, 0, len(sk.Next))
	for _, n := range sk.Next {
		lines = append(lines, "- `/"+n+"` — "+byName[n].Summary)
	}
	return strings.Join(lines, "\n"), nil
}

// indent prefixes every line of text with n spaces.
func indent(n int, text string) string {
	pad := strings.Repeat(" ", n)
	return pad + strings.ReplaceAll(text, "\n", "\n"+pad)
}
