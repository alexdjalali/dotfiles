package target

import "claudegen/model"

// KindProbity renders .claude/src/probity/probity.config.ts.tmpl to
// .claude/templates/probity/probity.config.ts, the Probity config a project
// copies when it opts into the TDD steering hook (ADR-0003).
const KindProbity = "probity"

// ProbityTarget renders the Probity config template, whose addendum carries
// the summaries of the rules targeting probity.
type ProbityTarget struct{}

// Kind returns KindProbity.
func (ProbityTarget) Kind() string { return KindProbity }

// Render executes the template and prefixes the marker as a TypeScript line
// comment, since WithMarker's HTML comment is not valid TypeScript.
func (ProbityTarget) Render(m *model.Model) ([]File, error) {
	body, err := execFile(m, srcPath(m, "probity/probity.config.ts.tmpl"), m)
	if err != nil {
		return nil, err
	}
	data := append([]byte("// "+Marker+"\n"), body...)
	return []File{{Path: ".claude/templates/probity/probity.config.ts", Data: data}}, nil
}
