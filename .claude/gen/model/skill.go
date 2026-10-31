package model

// Skill is one .claude/src/skills/<name>.yaml.
type Skill struct {
	// Name is the command name; it must equal the file stem.
	Name string `yaml:"name,omitempty"`

	// Description says what the skill does and when to use it.
	Description string `yaml:"description,omitempty"`

	// WhenToUse adds trigger phrases to the skill listing.
	WhenToUse string `yaml:"when_to_use,omitempty"`

	// Summary is the one-line text other skills' Next Step lists show.
	Summary string `yaml:"summary,omitempty"`

	// Role names the models.yaml role supplying model and effort.
	Role string `yaml:"role,omitempty"`

	// Model overrides the role's model.
	Model string `yaml:"model,omitempty"`

	// Effort overrides the role's effort.
	Effort string `yaml:"effort,omitempty"`

	// Context is "fork" to run in a forked subagent.
	Context string `yaml:"context,omitempty"`

	// Agent is the subagent type when Context is fork.
	Agent string `yaml:"agent,omitempty"`

	// Background controls whether a forked skill runs in the background.
	Background *bool `yaml:"background,omitempty"`

	// ArgumentHint is shown during autocomplete.
	ArgumentHint string `yaml:"argument_hint,omitempty"`

	// DisableModelInvocation makes the skill user-typed only.
	DisableModelInvocation *bool `yaml:"disable_model_invocation,omitempty"`

	// UserInvocable false hides the skill from the / menu.
	UserInvocable *bool `yaml:"user_invocable,omitempty"`

	// Next lists the skills the Next Step block offers.
	Next []string `yaml:"next,omitempty"`

	// Inject lists shell commands rendered as !`cmd` lines before the body.
	Inject []string `yaml:"inject,omitempty"`

	// File is the source file the skill was loaded from (set by Load).
	File string `yaml:"-"`
}
