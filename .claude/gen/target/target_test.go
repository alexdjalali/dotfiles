package target_test

import (
	"strings"
	"testing"

	"claudegen/target"
)

// A typo in gen.yaml must not silently skip a target.
func TestSelectUnknownKindFails(t *testing.T) {
	_, err := target.Default().Select([]string{"rules", "c"})
	if err == nil {
		t.Fatal("Select accepted an unknown kind")
	}
	msg := err.Error()
	if !strings.Contains(msg, "unknown_kind") || !strings.Contains(msg, `"c"`) || !strings.Contains(msg, "agents-md, claude-md, cursor") {
		t.Fatalf("error = %q", msg)
	}
}

// Later targets may rely on earlier ones' output order in reports.
func TestSelectPreservesOrder(t *testing.T) {
	ts, err := target.Default().Select([]string{"skills", "rules"})
	if err != nil {
		t.Fatal(err)
	}
	if len(ts) != 2 || ts[0].Kind() != "skills" || ts[1].Kind() != "rules" {
		t.Fatalf("kinds = %v", ts)
	}
}

// A missing gen.yaml must render nothing rather than everything.
func TestNoTargetsSelectsNothing(t *testing.T) {
	ts, err := target.Default().Select(nil)
	if err != nil || len(ts) != 0 {
		t.Fatalf("targets = %v, err = %v", ts, err)
	}
}
