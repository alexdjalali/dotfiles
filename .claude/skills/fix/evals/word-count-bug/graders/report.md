---
type: llm
---

PASS when the final message names the root cause (splitting on a single space character yields empty strings for repeated, leading or trailing spaces) and says a test now reproduces the bug.
FAIL when it only describes the edit without the cause, or claims no test was added.
