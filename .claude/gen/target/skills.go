package target

import (
	"bytes"
	"path/filepath"
	"strconv"

	"gopkg.in/yaml.v3"

	"claudegen/model"
)

// KindSkills renders .claude/src/skills/<name>.{yaml,md.tmpl} to
// .claude/skills/<name>/SKILL.md.
const KindSkills = "skills"

// SkillsTarget renders every skill Claude Code loads from ~/.claude/skills.
type SkillsTarget struct{}

// Kind returns KindSkills.
func (SkillsTarget) Kind() string { return KindSkills }

// Owns returns .claude/skills, so a removed skill's SKILL.md is an orphan.
func (SkillsTarget) Owns() []string { return []string{".claude/skills"} }

// Render writes each skill: frontmatter (marker first), the injected
// !`cmd` lines, then the executed body template.
func (SkillsTarget) Render(m *model.Model) ([]File, error) {
	files := make([]File, 0, len(m.Skills))
	for _, sk := range m.Skills {
		front, err := frontmatter(m, sk)
		if err != nil {
			return nil, err
		}
		body, err := execFile(m, srcPath(m, "skills/"+sk.File+".md.tmpl"), m)
		if err != nil {
			return nil, err
		}
		var buf bytes.Buffer
		buf.WriteString("---\n# " + Marker + "\n")
		buf.Write(front)
		buf.WriteString("---\n\n")
		for _, cmd := range sk.Inject {
			buf.WriteString("!`")
			buf.WriteString(cmd)
			buf.WriteString("`\n")
		}
		if len(sk.Inject) > 0 {
			buf.WriteString("\n")
		}
		buf.Write(body)
		files = append(files, File{Path: filepath.Join(".claude/skills", sk.Name, "SKILL.md"), Data: buf.Bytes()})
	}
	return files, nil
}

// frontmatter renders a skill's YAML keys in a fixed order, resolving model
// and effort from its role and omitting unset keys.
func frontmatter(m *model.Model, sk model.Skill) ([]byte, error) {
	role := m.Models[sk.Role]
	pairs := [][2]string{
		{"name", sk.Name},
		{"model", firstSet(sk.Model, role.Model)},
		{"effort", firstSet(sk.Effort, role.Effort)},
		{"context", sk.Context},
		{"agent", sk.Agent},
		{"background", boolText(sk.Background)},
		{"description", sk.Description},
		{"when_to_use", sk.WhenToUse},
		{"argument-hint", sk.ArgumentHint},
		{"disable-model-invocation", boolText(sk.DisableModelInvocation)},
		{"user-invocable", boolText(sk.UserInvocable)},
	}
	doc := &yaml.Node{Kind: yaml.MappingNode}
	for _, p := range pairs {
		if p[1] == "" {
			continue
		}
		val := &yaml.Node{Kind: yaml.ScalarNode, Value: p[1]}
		if p[1] == "true" || p[1] == "false" {
			val.Tag = "!!bool"
		}
		doc.Content = append(doc.Content, &yaml.Node{Kind: yaml.ScalarNode, Value: p[0]}, val)
	}
	out, err := yaml.Marshal(doc)
	if err != nil {
		return nil, model.Wrap(err, model.CodeInvalidModel, "skills/"+sk.File+".yaml")
	}
	return out, nil
}

// firstSet returns the first non-empty value.
func firstSet(values ...string) string {
	for _, v := range values {
		if v != "" {
			return v
		}
	}
	return ""
}

// boolText renders an optional bool; nil is unset.
func boolText(b *bool) string {
	if b == nil {
		return ""
	}
	return strconv.FormatBool(*b)
}
