package target

import "claudegen/model"

// KindAgentsMd renders .claude/src/agents.md.tmpl to codex/AGENTS.md.
const KindAgentsMd = "agents-md"

// AgentsMdTarget renders the AGENTS.md Codex reads.
type AgentsMdTarget struct{}

// Kind returns KindAgentsMd.
func (AgentsMdTarget) Kind() string { return KindAgentsMd }

// Render executes agents.md.tmpl, which composes Cursor rule bodies with
// {{mirror NAME}}; AGENTS.md has no frontmatter, so the marker is an HTML
// comment on line 1.
func (AgentsMdTarget) Render(m *model.Model) ([]File, error) {
	body, err := execFile(m, srcPath(m, "agents.md.tmpl"), m)
	if err != nil {
		return nil, err
	}
	return []File{{Path: "codex/AGENTS.md", Data: WithMarker(body)}}, nil
}
