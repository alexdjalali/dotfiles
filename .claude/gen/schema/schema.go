// Package schema embeds the JSON Schemas that constrain each source file kind.
package schema

import "embed"

// FS holds gen.json, models.json, rules.json and skill.json.
//
//go:embed *.json
var FS embed.FS
