package model

import "fmt"

// Code classifies a claude-gen failure; the CLI's exit status derives from it.
type Code string

const (
	// CodeInvalidModel marks a source file that fails to parse or validate.
	CodeInvalidModel Code = "invalid_model"

	// CodeUnknownKind marks a gen.yaml target with no registered Target.
	CodeUnknownKind Code = "unknown_kind"

	// CodeDrift marks generated files that differ from a fresh render.
	CodeDrift Code = "drift"

	// CodeIO marks a filesystem read or write failure.
	CodeIO Code = "io"
)

// CodedError is an error carrying a Code, a message and an optional cause.
type CodedError struct {
	// Code classifies the failure.
	Code Code

	// Msg describes the failure, naming the file involved.
	Msg string

	// Err is the underlying cause, if any.
	Err error
}

// Error formats the error as "<code>: <msg>[: <cause>]".
func (e *CodedError) Error() string {
	if e.Err != nil {
		return fmt.Sprintf("%s: %s: %v", e.Code, e.Msg, e.Err)
	}
	return fmt.Sprintf("%s: %s", e.Code, e.Msg)
}

// Unwrap returns the cause so errors.Is / errors.As see through the code.
func (e *CodedError) Unwrap() error { return e.Err }

// Wrap returns a CodedError with code and msg around err.
func Wrap(err error, code Code, msg string) error {
	return &CodedError{Code: code, Msg: msg, Err: err}
}

// New returns a CodedError with code and msg and no cause.
func New(code Code, msg string) error {
	return &CodedError{Code: code, Msg: msg}
}
