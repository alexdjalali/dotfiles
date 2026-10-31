// Command claude-gen renders the agent config (rules, skills, CLAUDE.md, the
// guard table, the Cursor, Kilocode and Codex mirrors) from the typed model
// in .claude/src, or with --check reports where the files on disk differ.
//
//	go -C .claude/gen run . --root "$PWD" [--check]
package main

import (
	"flag"
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"strings"

	"claudegen/model"
	"claudegen/target"
	"claudegen/writer"
)

// main runs the CLI and exits with its status.
func main() {
	os.Exit(run(os.Args[1:], os.Stdout, os.Stderr))
}

// run parses args, renders every selected target and writes or checks the
// result. It returns 0 on success, 1 on an invalid model, unknown kind or
// drift, and 2 on a usage error, including --check with no target enabled
// (a vacuous pass would hide a wrong --root).
func run(args []string, stdout, stderr io.Writer) int {
	fl := flag.NewFlagSet("claude-gen", flag.ContinueOnError)
	fl.SetOutput(stderr)
	root := fl.String("root", "", "repository root (default: git toplevel of the cwd)")
	check := fl.Bool("check", false, "report drift instead of writing; exit 1 on any")
	if err := fl.Parse(args); err != nil {
		return 2
	}
	if *root == "" {
		*root = defaultRoot()
	}
	files, owned, selected, err := render(*root, stderr)
	if err != nil {
		_, _ = fmt.Fprintln(stderr, err)
		return 1
	}
	if *check && selected == 0 {
		_, _ = fmt.Fprintf(stderr, "claude-gen: --check: nothing to check: %s lists no targets\n",
			filepath.Join(*root, ".claude", "src", "gen.yaml"))
		return 2
	}
	if *check {
		return report(writer.Check(*root, files, owned), stdout, stderr)
	}
	if err := writer.Write(*root, files, owned); err != nil {
		_, _ = fmt.Fprintln(stderr, err)
		return 1
	}
	_, _ = fmt.Fprintf(stdout, "claude-gen: wrote %d files\n", len(files))
	return 0
}

// render loads and validates the model, then renders every selected target,
// returning the files, the directories the targets own, and how many targets
// were selected. Validation errors are printed one per line before the error
// is returned.
func render(root string, stderr io.Writer) ([]target.File, []string, int, error) {
	m, err := model.Load(root)
	if err != nil {
		return nil, nil, 0, err
	}
	if errs := model.Validate(m); len(errs) > 0 {
		for _, e := range errs {
			_, _ = fmt.Fprintln(stderr, e.String())
		}
		return nil, nil, 0, model.New(model.CodeInvalidModel, fmt.Sprintf("%d validation errors", len(errs)))
	}
	targets, err := target.Default().Select(m.Gen.Targets)
	if err != nil {
		return nil, nil, 0, err
	}
	var files []target.File
	var owned []string
	for _, t := range targets {
		fs, err := t.Render(m)
		if err != nil {
			return nil, nil, 0, err
		}
		files = append(files, fs...)
		owned = append(owned, target.Owned(t)...)
	}
	return files, owned, len(targets), nil
}

// report prints each drift and returns 1 if there was any.
func report(drift []writer.Drift, stdout, stderr io.Writer) int {
	if len(drift) == 0 {
		_, _ = fmt.Fprintln(stdout, "claude-gen: no drift")
		return 0
	}
	for _, d := range drift {
		_, _ = fmt.Fprintf(stderr, "%s: %s %s\n", model.CodeDrift, d.Kind, d.Path)
	}
	_, _ = fmt.Fprintln(stderr, "regenerate with: go -C .claude/gen run . --root \"$PWD\"")
	return 1
}

// defaultRoot is the git toplevel of the working directory, else the
// working directory.
func defaultRoot() string {
	out, err := exec.Command("git", "rev-parse", "--show-toplevel").Output()
	if err == nil {
		return strings.TrimSpace(string(out))
	}
	wd, _ := os.Getwd()
	return filepath.Clean(wd)
}
