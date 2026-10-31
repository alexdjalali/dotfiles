package model

import (
	"errors"
	"io/fs"
	"os"
	"path/filepath"
	"sort"
	"strings"

	"gopkg.in/yaml.v3"
)

// SrcDir is the source directory relative to the repository root.
const SrcDir = ".claude/src"

// Load reads gen.yaml, models.yaml, rules.yaml and skills/*.yaml under
// root/.claude/src. A missing file loads as empty; malformed YAML is an
// invalid_model error naming the file.
func Load(root string) (*Model, error) {
	m := &Model{Root: root, Models: map[string]ModelRole{}}
	src := filepath.Join(root, SrcDir)
	if err := readYAML(filepath.Join(src, "gen.yaml"), &m.Gen); err != nil {
		return nil, err
	}
	if err := readYAML(filepath.Join(src, "models.yaml"), &m.Models); err != nil {
		return nil, err
	}
	if err := readYAML(filepath.Join(src, "rules.yaml"), &m.Rules); err != nil {
		return nil, err
	}
	skills, err := loadSkills(filepath.Join(src, "skills"))
	if err != nil {
		return nil, err
	}
	m.Skills = skills
	return m, nil
}

// loadSkills reads every *.yaml in dir, sorted by file name.
func loadSkills(dir string) ([]Skill, error) {
	paths, err := filepath.Glob(filepath.Join(dir, "*.yaml"))
	if err != nil {
		return nil, Wrap(err, CodeIO, dir)
	}
	sort.Strings(paths)
	skills := make([]Skill, 0, len(paths))
	for _, p := range paths {
		var s Skill
		if err := readYAML(p, &s); err != nil {
			return nil, err
		}
		s.File = strings.TrimSuffix(filepath.Base(p), ".yaml")
		if _, err := os.Stat(filepath.Join(dir, s.File+".md.tmpl")); err == nil {
			s.HasTemplate = true
		}
		skills = append(skills, s)
	}
	return skills, nil
}

// readYAML decodes path into out; a missing file leaves out unchanged.
func readYAML(path string, out any) error {
	data, err := os.ReadFile(path)
	if errors.Is(err, fs.ErrNotExist) {
		return nil
	}
	if err != nil {
		return Wrap(err, CodeIO, path)
	}
	if err := yaml.Unmarshal(data, out); err != nil {
		return Wrap(err, CodeInvalidModel, path)
	}
	return nil
}
