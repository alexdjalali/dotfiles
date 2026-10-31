package target

import (
	"text/template"

	"claudegen/model"
)

// FuncMap returns the template functions every target's templates share,
// bound to m.
func FuncMap(m *model.Model) template.FuncMap {
	return template.FuncMap{}
}
