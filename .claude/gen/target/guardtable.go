package target

import (
	"encoding/json"

	"claudegen/model"
)

// KindGuardTable renders the Bash guard's rows to .claude/scripts/guard_rules.json.
const KindGuardTable = "guard-table"

// GuardTableTarget renders one row per bash-guard rule for guard_rows.py.
type GuardTableTarget struct{}

// guardRow is one row of guard_rules.json: the rule id and its guard block.
type guardRow struct {
	// ID is the rule id, printed in reports.
	ID string `json:"id"`

	*model.Guard
}

// guardTable is the whole guard_rules.json document.
type guardTable struct {
	// Generated carries the marker, since JSON has no comments.
	Generated string `json:"_generated"`

	// Rows are the bash-guard rules in catalog order.
	Rows []guardRow `json:"rows"`
}

// Kind returns KindGuardTable.
func (GuardTableTarget) Kind() string { return KindGuardTable }

// Render marshals every bash-guard rule's guard block, in catalog order.
func (GuardTableTarget) Render(m *model.Model) ([]File, error) {
	table := guardTable{Generated: Marker, Rows: []guardRow{}}
	for _, r := range m.Rules {
		if r.Hook == "bash-guard" && r.Guard != nil {
			table.Rows = append(table.Rows, guardRow{ID: r.ID, Guard: r.Guard})
		}
	}
	data, err := json.MarshalIndent(table, "", "  ")
	if err != nil {
		return nil, model.Wrap(err, model.CodeInvalidModel, "guard table")
	}
	return []File{{Path: ".claude/scripts/guard_rules.json", Data: append(data, '\n')}}, nil
}
