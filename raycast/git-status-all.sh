#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Git Status All Projects
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 📊
# @raycast.packageName Developer Tools

# Documentation:
# @raycast.description Check git status of all projects
# @raycast.author Alex Djalali

PROJECT_DIRS="$HOME/projects"

echo "🔍 Scanning projects for uncommitted changes..."
echo ""

for dir in $PROJECT_DIRS/*/; do
    if [ -d "$dir/.git" ]; then
        cd "$dir"
        STATUS=$(git status --porcelain 2>/dev/null)
        BRANCH=$(git branch --show-current 2>/dev/null)

        if [ -n "$STATUS" ]; then
            NAME=$(basename "$dir")
            CHANGES=$(echo "$STATUS" | wc -l | tr -d ' ')
            echo "📁 $NAME ($BRANCH) - $CHANGES uncommitted changes"
        fi
    fi
done

echo ""
echo "✅ Scan complete"
