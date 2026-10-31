package target

import (
	"bytes"
	"os"
	"path/filepath"
	"text/template"

	"claudegen/model"
)

// srcPath joins a path under .claude/src to the model's root.
func srcPath(m *model.Model, rel string) string {
	return filepath.Join(m.Root, model.SrcDir, rel)
}

// execFile parses and executes the template at path with the shared FuncMap.
// Errors are invalid_model and name the template file.
func execFile(m *model.Model, path string, data any) ([]byte, error) {
	text, err := os.ReadFile(path)
	if err != nil {
		return nil, model.Wrap(err, model.CodeIO, path)
	}
	return execText(m, filepath.Base(path), string(text), data)
}

// execText parses and executes text as a template named name.
func execText(m *model.Model, name, text string, data any) ([]byte, error) {
	tmpl, err := template.New(name).Option("missingkey=error").Funcs(FuncMap(m)).Parse(text)
	if err != nil {
		return nil, model.Wrap(err, model.CodeInvalidModel, name)
	}
	var buf bytes.Buffer
	if err := tmpl.Execute(&buf, data); err != nil {
		return nil, model.Wrap(err, model.CodeInvalidModel, name)
	}
	return buf.Bytes(), nil
}
