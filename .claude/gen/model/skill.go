package model

// Skill is one .claude/src/skills/<name>.yaml.
type Skill struct {
	// Name is the command name; it must equal the file stem.
	Name string `yaml:"name"`

	// Description says what the skill does and when to use it.
	Description string `yaml:"description"`

	// WhenToUse adds trigger phrases to the skill listing.
	WhenToUse string `yaml:"when_to_use"`

	// Summary is the one-line text other skills' Next Step lists show.
	Summary string `yaml:"summary"`

	// Role names the models.yaml role supplying model and effort.
	Role string `yaml:"role"`

	// Model overrides the role's model.
	Model string `yaml:"model"`

	// Effort overrides the role's effort.
	Effort string `yaml:"effort"`

	// Context is "fork" to run in a forked subagent.
	Context string `yaml:"context"`

	// Agent is the subagent type when Context is fork.
	Agent string `yaml:"agent"`

	// Background controls whether a forked skill runs in the background.
	Background *bool `yaml:"background"`

	// ArgumentHint is shown during autocomplete.
	ArgumentHint string `yaml:"argument_hint"`

	// DisableModelInvocation makes the skill user-typed only.
	DisableModelInvocation *bool `yaml:"disable_model_invocation"`

	// UserInvocable false hides the skill from the / menu.
	UserInvocable *bool `yaml:"user_invocable"`

	// Next lists the skills the Next Step block offers.
	Next []string `yaml:"next"`

	// Inject lists shell commands rendered as !`cmd` lines before the body.
	Inject []string `yaml:"inject"`

	// File is the source file the skill was loaded from (set by Load).
	File string `yaml:"-"`
}
