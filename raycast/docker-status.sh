#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Docker Status
# @raycast.mode inline

# Optional parameters:
# @raycast.icon 🐳
# @raycast.packageName Developer Tools
# @raycast.refreshTime 30s

# Documentation:
# @raycast.description Show running Docker containers
# @raycast.author Alex Djalali

if ! docker info > /dev/null 2>&1; then
    echo "Docker not running"
    exit 0
fi

RUNNING=$(docker ps -q | wc -l | tr -d ' ')
TOTAL=$(docker ps -aq | wc -l | tr -d ' ')

echo "🐳 $RUNNING running / $TOTAL total"
