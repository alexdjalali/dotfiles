package target

import (
	"fmt"
	"sort"
	"strings"

	"claudegen/model"
)

// File is one rendered output: a repo-relative path and its bytes.
type File struct {
	// Path is relative to the repository root.
	Path string

	// Data is the full file content.
	Data []byte
}

// Target renders one output kind from the model.
type Target interface {
	// Kind is the name gen.yaml uses to select the target.
	Kind() string

	// Render returns every file this target owns.
	Render(m *model.Model) ([]File, error)
}

// Registry maps a kind to the constructor of its Target.
type Registry struct {
	// ctors holds one constructor per registered kind.
	ctors map[string]func() Target
}

// NewRegistry returns an empty Registry.
func NewRegistry() *Registry {
	return &Registry{ctors: map[string]func() Target{}}
}

// Register adds ctor under kind, replacing any earlier registration.
func (r *Registry) Register(kind string, ctor func() Target) {
	r.ctors[kind] = ctor
}

// Kinds returns the registered kinds, sorted.
func (r *Registry) Kinds() []string {
	kinds := make([]string, 0, len(r.ctors))
	for k := range r.ctors {
		kinds = append(kinds, k)
	}
	sort.Strings(kinds)
	return kinds
}

// Select builds the targets for kinds, in order. An unknown kind is an
// unknown_kind error listing the known kinds.
func (r *Registry) Select(kinds []string) ([]Target, error) {
	out := make([]Target, 0, len(kinds))
	for _, k := range kinds {
		ctor, ok := r.ctors[k]
		if !ok {
			msg := fmt.Sprintf("target %q is not registered (known: %s)", k, strings.Join(r.Kinds(), ", "))
			return nil, model.New(model.CodeUnknownKind, msg)
		}
		out = append(out, ctor())
	}
	return out, nil
}

// Default returns a Registry holding every built-in target.
func Default() *Registry {
	r := NewRegistry()
	r.Register(KindRules, func() Target { return RulesTarget{} })
	r.Register(KindClaudeMd, func() Target { return ClaudeMdTarget{} })
	r.Register(KindGuardTable, func() Target { return GuardTableTarget{} })
	return r
}

// Owner is implemented by a target that owns whole directories, so a marked
// file left there by a removed template is found as an orphan.
type Owner interface {
	// Owns returns repo-relative directories the target owns.
	Owns() []string
}

// Owned returns the directories t owns for orphan cleanup: its Owns() when
// it is an Owner, else none. A target that renders single files never claims
// their directory, which may hold other generated files.
func Owned(t Target) []string {
	if o, ok := t.(Owner); ok {
		return o.Owns()
	}
	return nil
}
