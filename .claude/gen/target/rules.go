package target

import (
	"path/filepath"
	"sort"
	"strings"

	"claudegen/model"
)

// KindRules renders .claude/src/rules/<name>.md.tmpl to .claude/rules/<name>.md.
const KindRules = "rules"

// RulesTarget renders the rule files Claude Code loads from ~/.claude/rules.
type RulesTarget struct{}

// Kind returns KindRules.
func (RulesTarget) Kind() string { return KindRules }

// Owns returns .claude/rules, so a removed template's output is an orphan.
func (RulesTarget) Owns() []string { return []string{".claude/rules"} }

// Render executes every rule template, in file-name order.
func (RulesTarget) Render(m *model.Model) ([]File, error) {
	paths, err := filepath.Glob(srcPath(m, "rules/*.md.tmpl"))
	if err != nil {
		return nil, model.Wrap(err, model.CodeIO, "rules")
	}
	sort.Strings(paths)
	files := make([]File, 0, len(paths))
	for _, p := range paths {
		body, err := execFile(m, p, m)
		if err != nil {
			return nil, err
		}
		name := strings.TrimSuffix(filepath.Base(p), ".tmpl")
		files = append(files, File{Path: filepath.Join(".claude/rules", name), Data: WithMarker(body)})
	}
	return files, nil
}
