package model

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"regexp"
	"strings"

	"github.com/santhosh-tekuri/jsonschema/v6"
	"github.com/santhosh-tekuri/jsonschema/v6/kind"
	"golang.org/x/text/language"
	"golang.org/x/text/message"
	"gopkg.in/yaml.v3"

	"claudegen/schema"
)

// Error is one validation failure in a source file.
type Error struct {
	// Path is the source file, relative to .claude/src.
	Path string

	// Field is the JSON pointer of the offending value, e.g. /0/severity.
	Field string

	// Message says what is wrong.
	Message string
}

// String formats the error as path:field: message.
func (e Error) String() string {
	return fmt.Sprintf("%s:%s: %s", e.Path, e.Field, e.Message)
}

// printer renders schema error kinds as English text.
var printer = message.NewPrinter(language.English)

// Validate checks every source file against its schema, then the
// cross-references schemas cannot express. It returns every error found.
func Validate(m *Model) []Error {
	var errs []Error
	errs = append(errs, checkSchema("gen.json", "gen.yaml", m.Gen)...)
	errs = append(errs, checkSchema("models.json", "models.yaml", m.Models)...)
	errs = append(errs, checkSchema("rules.json", "rules.yaml", m.Rules)...)
	errs = append(errs, checkRuleIDs(m.Rules)...)
	errs = append(errs, checkEmphasis(m.Rules)...)
	for _, sk := range m.Skills {
		errs = append(errs, checkSkill(m, sk)...)
	}
	return errs
}

// emphasis matches the markers a machine-enforced rule may not use.
var emphasis = regexp.MustCompile(`⛔|\bNEVER\b|\bMUST\b`)

// checkEmphasis reports hook- and lint-enforced rules whose statement uses
// emphasis: the check enforces them, so the prose states them plainly.
func checkEmphasis(rules []Rule) []Error {
	var errs []Error
	for i, r := range rules {
		if (r.Enforce == "hook" || r.Enforce == "lint") && emphasis.MatchString(r.Statement) {
			msg := fmt.Sprintf("rule %q is enforced by %s; remove ⛔/NEVER/MUST", r.ID, r.Enforce)
			errs = append(errs, Error{"rules.yaml", fmt.Sprintf("/%d/statement", i), msg})
		}
	}
	return errs
}

// descriptionBudget is the skill-listing cap on description + when_to_use.
const descriptionBudget = 1536

// checkSkill validates one skill against skill.json and its cross-references:
// name equals the file stem, the description fits the listing budget, the
// role exists, and every next edge names a skill.
func checkSkill(m *Model, sk Skill) []Error {
	path := "skills/" + sk.File + ".yaml"
	errs := checkSchema("skill.json", path, sk)
	if sk.Name != "" && sk.Name != sk.File {
		errs = append(errs, Error{path, "/name", fmt.Sprintf("name %q must equal the file name %q", sk.Name, sk.File)})
	}
	if n := len([]rune(sk.Description)) + len([]rune(sk.WhenToUse)); n > descriptionBudget {
		errs = append(errs, Error{path, "/description", fmt.Sprintf("description + when_to_use is %d characters; the listing cuts at %d", n, descriptionBudget)})
	}
	if _, ok := m.Models[sk.Role]; sk.Role != "" && !ok {
		errs = append(errs, Error{path, "/role", fmt.Sprintf("role %q is not in models.yaml", sk.Role)})
	}
	names := map[string]bool{}
	for _, other := range m.Skills {
		names[other.Name] = true
	}
	for i, next := range sk.Next {
		if !names[next] {
			errs = append(errs, Error{path, fmt.Sprintf("/next/%d", i), fmt.Sprintf("next names unknown skill %q", next)})
		}
	}
	return errs
}

// checkRuleIDs reports every rule whose id repeats an earlier rule's.
func checkRuleIDs(rules []Rule) []Error {
	var errs []Error
	seen := map[string]bool{}
	for i, r := range rules {
		if seen[r.ID] {
			errs = append(errs, Error{"rules.yaml", fmt.Sprintf("/%d/id", i), fmt.Sprintf("duplicate rule id %q", r.ID)})
		}
		seen[r.ID] = true
	}
	return errs
}

// checkSchema validates value, as its YAML form, against the embedded schema file.
func checkSchema(schemaFile, path string, value any) []Error {
	inst, err := instance(value)
	if err != nil {
		return []Error{{path, "", err.Error()}}
	}
	sch, err := compile(schemaFile)
	if err != nil {
		return []Error{{path, "", err.Error()}}
	}
	verr := sch.Validate(inst)
	var ve *jsonschema.ValidationError
	if verr == nil {
		return nil
	}
	if !errors.As(verr, &ve) {
		return []Error{{path, "", verr.Error()}}
	}
	return leaves(path, ve)
}

// instance converts value to the JSON-shaped data the validator expects,
// going through YAML so field names match the source files.
func instance(value any) (any, error) {
	raw, err := yaml.Marshal(value)
	if err != nil {
		return nil, err
	}
	var generic any
	if err := yaml.Unmarshal(raw, &generic); err != nil {
		return nil, err
	}
	if generic == nil {
		generic = map[string]any{}
		if _, isList := value.([]Rule); isList {
			generic = []any{}
		}
	}
	js, err := json.Marshal(generic)
	if err != nil {
		return nil, err
	}
	return jsonschema.UnmarshalJSON(bytes.NewReader(js))
}

// compile loads one embedded schema.
func compile(file string) (*jsonschema.Schema, error) {
	data, err := schema.FS.ReadFile(file)
	if err != nil {
		return nil, err
	}
	doc, err := jsonschema.UnmarshalJSON(bytes.NewReader(data))
	if err != nil {
		return nil, err
	}
	c := jsonschema.NewCompiler()
	if err := c.AddResource(file, doc); err != nil {
		return nil, err
	}
	return c.Compile(file)
}

// leaves flattens a validation error tree to its leaf failures. A missing
// required property is reported at the property's own pointer.
func leaves(path string, ve *jsonschema.ValidationError) []Error {
	if len(ve.Causes) > 0 {
		var out []Error
		for _, c := range ve.Causes {
			out = append(out, leaves(path, c)...)
		}
		return out
	}
	loc := "/" + strings.Join(ve.InstanceLocation, "/")
	if req, ok := ve.ErrorKind.(*kind.Required); ok {
		out := make([]Error, 0, len(req.Missing))
		for _, name := range req.Missing {
			out = append(out, Error{path, strings.TrimSuffix(loc, "/") + "/" + name, "missing required field"})
		}
		return out
	}
	return []Error{{path, loc, ve.ErrorKind.LocalizedString(printer)}}
}
