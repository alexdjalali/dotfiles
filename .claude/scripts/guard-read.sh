#!/usr/bin/env bash
# guard-read.sh: TEMPORARY no-op. guard-read was removed (it never ran:
# nothing set CLAUDE_BULK_READ_TOOL), but sessions started before the removal
# still call this path from their hook snapshot. Delete this file once no
# session from before the settings change is running.
exit 0
