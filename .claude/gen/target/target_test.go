package target_test

import (
	"strings"
	"testing"

	"claudegen/model"
	"claudegen/target"
)

// stubTarget is a Target that renders nothing; it stands in for a registered kind.
type stubTarget struct{ kind string }

// Kind returns the stub's kind.
func (s stubTarget) Kind() string { return s.kind }

// Render returns no files.
func (s stubTarget) Render(*model.Model) ([]target.File, error) { return nil, nil }

// registry returns a Registry with kinds "a" and "b".
func registry() *target.Registry {
	r := target.NewRegistry()
	r.Register("b", func() target.Target { return stubTarget{"b"} })
	r.Register("a", func() target.Target { return stubTarget{"a"} })
	return r
}

// TestSelectUnknownKindFails tests the loud failure on an unknown kind.
//
// Why this test is important:
//   - A typo in gen.yaml must not silently skip a target.
//
// What it tests:
//   - Selecting "c" fails with unknown_kind and lists the known kinds sorted.
func TestSelectUnknownKindFails(t *testing.T) {
	_, err := registry().Select([]string{"a", "c"})
	if err == nil {
		t.Fatal("Select accepted an unknown kind")
	}
	msg := err.Error()
	if !strings.Contains(msg, "unknown_kind") || !strings.Contains(msg, `"c"`) || !strings.Contains(msg, "a, b") {
		t.Fatalf("error = %q", msg)
	}
}

// TestSelectPreservesOrder tests that targets come back in gen.yaml order.
//
// Why this test is important:
//   - Later targets may rely on earlier ones' output order in reports.
//
// What it tests:
//   - Selecting [b, a] returns kinds b then a.
func TestSelectPreservesOrder(t *testing.T) {
	ts, err := registry().Select([]string{"b", "a"})
	if err != nil {
		t.Fatal(err)
	}
	if len(ts) != 2 || ts[0].Kind() != "b" || ts[1].Kind() != "a" {
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
	ts, err := registry().Select(nil)
	if err != nil || len(ts) != 0 {
		t.Fatalf("targets = %v, err = %v", ts, err)
	}
}
