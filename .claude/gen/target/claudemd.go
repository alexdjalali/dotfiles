package target

import "claudegen/model"

// KindClaudeMd renders .claude/src/claude.md.tmpl to .claude/CLAUDE.md.
const KindClaudeMd = "claude-md"

// ClaudeMdTarget renders the global CLAUDE.md every session loads.
type ClaudeMdTarget struct{}

// Kind returns KindClaudeMd.
func (ClaudeMdTarget) Kind() string { return KindClaudeMd }

// Render executes claude.md.tmpl; CLAUDE.md has no frontmatter, so the
// marker is an HTML comment on line 1.
func (ClaudeMdTarget) Render(m *model.Model) ([]File, error) {
	body, err := execFile(m, srcPath(m, "claude.md.tmpl"), m)
	if err != nil {
		return nil, err
	}
	return []File{{Path: ".claude/CLAUDE.md", Data: WithMarker(body)}}, nil
}
