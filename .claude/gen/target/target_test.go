package target_test

import (
	"strings"
	"testing"

	"claudegen/target"
)

// TestSelectUnknownKindFails tests the loud failure on an unknown kind.
//
// Why this test is important:
//   - A typo in gen.yaml must not silently skip a target.
//
// What it tests:
//   - Selecting "c" from the built-in registry fails with unknown_kind and
//     lists the known kinds sorted.
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

// TestSelectPreservesOrder tests that targets come back in gen.yaml order.
//
// Why this test is important:
//   - Later targets may rely on earlier ones' output order in reports.
//
// What it tests:
//   - Selecting [skills, rules] returns kinds skills then rules.
func TestSelectPreservesOrder(t *testing.T) {
	ts, err := target.Default().Select([]string{"skills", "rules"})
	if err != nil {
		t.Fatal(err)
	}
	if len(ts) != 2 || ts[0].Kind() != "skills" || ts[1].Kind() != "rules" {
		t.Fatalf("kinds = %v", ts)
	}
}

// TestNoTargetsSelectsNothing tests the fail-safe empty default.
//
// Why this test is important:
//   - A missing gen.yaml must render nothing rather than everything.
//
// What it tests:
//   - Selecting nil returns no targets and no error.
func TestNoTargetsSelectsNothing(t *testing.T) {
	ts, err := target.Default().Select(nil)
	if err != nil || len(ts) != 0 {
		t.Fatalf("targets = %v, err = %v", ts, err)
	}
}
