package model

// Model is the whole loaded source tree.
type Model struct {
	// Root is the repository root the model was loaded from.
	Root string

	// Gen lists the enabled targets.
	Gen Gen

	// Models maps a role name to its model id and effort.
	Models map[string]ModelRole

	// Rules is the rule catalog in file order.
	Rules []Rule

	// Skills are the skills in file-name order.
	Skills []Skill
}

// Gen is .claude/src/gen.yaml.
type Gen struct {
	// Targets names the target kinds to render, in order; empty renders nothing.
	Targets []string `yaml:"targets,omitempty"`
}

// ModelRole is one entry of .claude/src/models.yaml.
type ModelRole struct {
	// Model is the model id or alias written to skill frontmatter.
	Model string `yaml:"model"`

	// Effort is the reasoning effort; empty leaves it unset.
	Effort string `yaml:"effort,omitempty"`
}

// Rule is one entry of the rule catalog, .claude/src/rules.yaml.
type Rule struct {
	// ID is the kebab-case name templates reference.
	ID string `yaml:"id"`

	// Statement is the full sentence rendered into Claude-facing files.
	Statement string `yaml:"statement,omitempty"`

	// Summary is the condensed sentence rendered into mirrors.
	Summary string `yaml:"summary,omitempty"`

	// Category groups the rule in review and audit lists.
	Category string `yaml:"category,omitempty"`

	// Severity is must_fix, should_fix or suggestion.
	Severity string `yaml:"severity,omitempty"`

	// Enforce is how the rule is enforced: hook, lint, review or prose.
	Enforce string `yaml:"enforce,omitempty"`

	// Hook names the hook enforcing the rule when Enforce is hook: bash-guard
	// (a guard_rules.json row), bash-guard-builtin (a check coded in
	// guard_bash.py) or edit-guard (guard-generated.sh).
	Hook string `yaml:"hook,omitempty"`

	// Paths are globs limiting where the rule applies; empty means everywhere.
	Paths []string `yaml:"paths,omitempty"`

	// Targets name the templates or lists the rule renders into.
	Targets []string `yaml:"targets,omitempty"`

	// Guard is the Bash guard row, required when Hook is bash-guard.
	Guard *Guard `yaml:"guard,omitempty"`
}

// Guard is the data a bash-guard rule contributes to guard_rules.json.
type Guard struct {
	// Argv0 is the program the row applies to, e.g. git.
	Argv0 string `yaml:"argv0" json:"argv0"`

	// Subcommands are the subcommands the row applies to.
	Subcommands []string `yaml:"subcommands" json:"subcommands"`

	// Flags maps a subcommand (or "all") to the flags it bans.
	Flags map[string][]string `yaml:"flags" json:"flags"`

	// Env maps an environment variable to the values it bans.
	Env map[string][]string `yaml:"env" json:"env"`

	// Config lists git config keys the row bans overriding: per command
	// (-c, --config-env, GIT_CONFIG_KEY_n) on a listed subcommand, and
	// written or unset with `git config`.
	Config []string `yaml:"config,omitempty" json:"config,omitempty"`

	// Reason is printed when the row blocks a command.
	Reason string `yaml:"reason" json:"reason"`
}
