package target_test

import (
	"encoding/json"
	"os"
	"testing"
)

// TestGuardTableGolden tests the guard-table target against its golden file.
//
// Why this test is important:
//   - guard_bash.py blocks commands from this table; a wrong key lets a
//     hook bypass through.
//
// What it tests:
//   - A bash-guard rule renders as one row in .claude/scripts/guard_rules.json,
//     config keys included, with the marker under "_generated".
func TestGuardTableGolden(t *testing.T) {
	files := renderLoaded(t, "guard-table", "../testdata/guardtable")
	want, err := os.ReadFile("../testdata/guardtable/golden.json")
	if err != nil {
		t.Fatal(err)
	}
	if len(files) != 1 || files[0].Path != ".claude/scripts/guard_rules.json" {
		t.Fatalf("files = %+v", files)
	}
	if string(files[0].Data) != string(want) {
		t.Fatalf("got:\n%s\nwant:\n%s", files[0].Data, want)
	}
}

// TestGuardTableOmitsNonBashRules tests row selection.
//
// Why this test is important:
//   - Only bash-guard rules have a row; an edit-guard rule in the table
//     would be an empty, meaningless row.
//
// What it tests:
//   - Of a bash-guard and an edit-guard rule, only the bash-guard one
//     (no-verify) becomes a row.
func TestGuardTableOmitsNonBashRules(t *testing.T) {
	files := renderLoaded(t, "guard-table", "../testdata/guardtable")
	var table struct {
		Rows []struct {
			ID string `json:"id"`
		} `json:"rows"`
	}
	if err := json.Unmarshal(files[0].Data, &table); err != nil {
		t.Fatal(err)
	}
	if len(table.Rows) != 1 || table.Rows[0].ID != "no-verify" {
		t.Fatalf("rows = %+v", table.Rows)
	}
}
