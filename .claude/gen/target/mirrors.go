package target

import (
	"bytes"
	"path/filepath"
	"regexp"
	"sort"
	"strings"

	"claudegen/model"
)

// KindCursor renders .claude/src/mirrors/cursor/<name>.mdc.tmpl to
// cursor/rules/<name>.mdc.
const KindCursor = "cursor"

// KindKilocode renders the Cursor rules, reshaped, to kilocode/rules/<name>.md.
const KindKilocode = "kilocode"

// CursorTarget renders the condensed rules Cursor loads.
type CursorTarget struct{}

// Kind returns KindCursor.
func (CursorTarget) Kind() string { return KindCursor }

// Owns returns cursor/rules, so a removed template's output is an orphan.
func (CursorTarget) Owns() []string { return []string{"cursor/rules"} }

// Render executes every Cursor template; the marker goes inside the
// frontmatter.
func (CursorTarget) Render(m *model.Model) ([]File, error) {
	files, err := renderCursor(m)
	if err != nil {
		return nil, err
	}
	for i := range files {
		files[i].Data = WithMarker(files[i].Data)
	}
	return files, nil
}

// KilocodeTarget renders the rules Kilocode loads: each Cursor rule without
// its frontmatter.
type KilocodeTarget struct{}

// Kind returns KindKilocode.
func (KilocodeTarget) Kind() string { return KindKilocode }

// Owns returns kilocode/rules, so a removed template's output is an orphan.
func (KilocodeTarget) Owns() []string { return []string{"kilocode/rules"} }

// Render reshapes the Cursor rules itself, so it works with or without the
// cursor target selected.
func (KilocodeTarget) Render(m *model.Model) ([]File, error) {
	cursor, err := renderCursor(m)
	if err != nil {
		return nil, err
	}
	files := make([]File, 0, len(cursor))
	for _, f := range cursor {
		name := strings.TrimSuffix(filepath.Base(f.Path), ".mdc")
		if name == "typescript-react" {
			name = "typescript"
		}
		body := kilocodeRefs(stripFrontmatter(f.Data))
		files = append(files, File{Path: filepath.Join("kilocode/rules", name+".md"), Data: WithMarker(body)})
	}
	return files, nil
}

// renderCursor executes the Cursor templates in file-name order, without
// markers; both mirror targets build on it.
func renderCursor(m *model.Model) ([]File, error) {
	paths, err := filepath.Glob(srcPath(m, "mirrors/cursor/*.mdc.tmpl"))
	if err != nil {
		return nil, model.Wrap(err, model.CodeIO, "mirrors/cursor")
	}
	sort.Strings(paths)
	files := make([]File, 0, len(paths))
	for _, p := range paths {
		body, err := execFile(m, p, m)
		if err != nil {
			return nil, err
		}
		name := strings.TrimSuffix(filepath.Base(p), ".tmpl")
		files = append(files, File{Path: filepath.Join("cursor/rules", name), Data: body})
	}
	return files, nil
}

// stripFrontmatter drops a leading ---…--- block and one blank line after it.
func stripFrontmatter(body []byte) []byte {
	rest, ok := bytes.CutPrefix(body, []byte("---\n"))
	if !ok {
		return body
	}
	_, after, ok := bytes.Cut(rest, []byte("\n---\n"))
	if !ok {
		return body
	}
	return bytes.TrimPrefix(after, []byte("\n"))
}

// mdcRef matches a Cursor rule reference such as `python.mdc` (`.py` files).
var mdcRef = regexp.MustCompile("`([a-z-]+)\\.mdc` \\([^)]*files\\)")

// kilocodeRefs points Cursor rule references at the Kilocode file names.
func kilocodeRefs(body []byte) []byte {
	body = mdcRef.ReplaceAll(body, []byte("`$1.md`"))
	return bytes.ReplaceAll(body, []byte("`typescript-react.md`"), []byte("`typescript.md`"))
}
