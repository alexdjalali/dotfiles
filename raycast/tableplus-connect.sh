#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title TablePlus Connect
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🗄️
# @raycast.argument1 { "type": "text", "placeholder": "connection name (optional)", "optional": true }
# @raycast.packageName Developer Tools

# Documentation:
# @raycast.description Open TablePlus database client
# @raycast.author Alex Djalali

if [ -n "$1" ]; then
    # Open specific connection by name
    open "tableplus://?connection_name=$1"
else
    # Just open TablePlus
    open -a "TablePlus"
fi

echo "Opened TablePlus"
