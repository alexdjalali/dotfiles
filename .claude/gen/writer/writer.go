// Package writer applies a render to disk, or compares a render with disk.
package writer

import (
	"bufio"
	"bytes"
	"errors"
	"io/fs"
	"os"
	"path/filepath"
	"sort"
	"strings"

	"claudegen/model"
	"claudegen/target"
)

// markerLines is how many leading lines are searched for target.Marker.
const markerLines = 5

// Drift is one difference between a render and the files on disk.
type Drift struct {
	// Path is the repo-relative file.
	Path string

	// Kind is "differs", "missing" or "orphan".
	Kind string
}

// Write writes files under root (each atomically, via a temp file and rename)
// and deletes marked files under the owned directories that files lacks.
func Write(root string, files []target.File, owned []string) error {
	sorted := sortedFiles(files)
	for _, f := range sorted {
		if err := writeAtomic(filepath.Join(root, f.Path), f.Data); err != nil {
			return err
		}
	}
	orphans, err := findOrphans(root, files, owned)
	if err != nil {
		return err
	}
	for _, p := range orphans {
		if err := os.Remove(filepath.Join(root, p)); err != nil {
			return model.Wrap(err, model.CodeIO, p)
		}
	}
	return nil
}

// Check reports every file that differs from or is missing against files, and
// every marked orphan under the owned directories, sorted by path.
func Check(root string, files []target.File, owned []string) []Drift {
	var drift []Drift
	for _, f := range sortedFiles(files) {
		got, err := os.ReadFile(filepath.Join(root, f.Path))
		switch {
		case err != nil:
			drift = append(drift, Drift{f.Path, "missing"})
		case !bytes.Equal(got, f.Data):
			drift = append(drift, Drift{f.Path, "differs"})
		}
	}
	orphans, err := findOrphans(root, files, owned)
	if err != nil {
		return append(drift, Drift{err.Error(), "unreadable"})
	}
	for _, p := range orphans {
		drift = append(drift, Drift{p, "orphan"})
	}
	return drift
}

// sortedFiles returns files ordered by path.
func sortedFiles(files []target.File) []target.File {
	out := append([]target.File(nil), files...)
	sort.Slice(out, func(i, j int) bool { return out[i].Path < out[j].Path })
	return out
}

// writeAtomic writes data to path through a temp file in the same directory.
func writeAtomic(path string, data []byte) error {
	dir := filepath.Dir(path)
	if err := os.MkdirAll(dir, 0o755); err != nil {
		return model.Wrap(err, model.CodeIO, dir)
	}
	tmp, err := os.CreateTemp(dir, ".claude-gen-*")
	if err != nil {
		return model.Wrap(err, model.CodeIO, path)
	}
	defer func() { _ = os.Remove(tmp.Name()) }() // no-op after a successful rename
	if _, err := tmp.Write(data); err != nil {
		_ = tmp.Close() // the write error is the one to report
		return model.Wrap(err, model.CodeIO, path)
	}
	if err := tmp.Close(); err != nil {
		return model.Wrap(err, model.CodeIO, path)
	}
	if err := os.Chmod(tmp.Name(), 0o644); err != nil {
		return model.Wrap(err, model.CodeIO, path)
	}
	if err := os.Rename(tmp.Name(), path); err != nil {
		return model.Wrap(err, model.CodeIO, path)
	}
	return nil
}

// findOrphans lists marked files under the owned directories that no file in
// files produced, as sorted repo-relative paths.
func findOrphans(root string, files []target.File, owned []string) ([]string, error) {
	rendered := map[string]bool{}
	for _, f := range files {
		rendered[filepath.Clean(f.Path)] = true
	}
	var orphans []string
	for _, dir := range owned {
		err := filepath.WalkDir(filepath.Join(root, dir), func(p string, d fs.DirEntry, err error) error {
			if errors.Is(err, fs.ErrNotExist) {
				return nil
			}
			if err != nil || d.IsDir() {
				return err
			}
			rel, relErr := filepath.Rel(root, p)
			if relErr != nil {
				return relErr
			}
			if !rendered[rel] && IsMarked(p) {
				orphans = append(orphans, rel)
			}
			return nil
		})
		if err != nil {
			return nil, model.Wrap(err, model.CodeIO, dir)
		}
	}
	sort.Strings(orphans)
	return orphans, nil
}

// IsMarked reports whether one of the first lines of the file at path
// contains target.Marker. An unreadable file is not marked.
func IsMarked(path string) bool {
	f, err := os.Open(path)
	if err != nil {
		return false
	}
	defer func() { _ = f.Close() }() // read-only; a close error changes nothing
	sc := bufio.NewScanner(f)
	for i := 0; i < markerLines && sc.Scan(); i++ {
		if strings.Contains(sc.Text(), target.Marker) {
			return true
		}
	}
	return false
}
