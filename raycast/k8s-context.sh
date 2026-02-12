#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Kubernetes Context
# @raycast.mode inline

# Optional parameters:
# @raycast.icon ☸️
# @raycast.packageName Developer Tools
# @raycast.refreshTime 60s

# Documentation:
# @raycast.description Show current Kubernetes context
# @raycast.author Alex Djalali

if ! command -v kubectl &> /dev/null; then
    echo "kubectl not installed"
    exit 0
fi

CTX=$(kubectl config current-context 2>/dev/null || echo "none")
NS=$(kubectl config view --minify -o jsonpath='{..namespace}' 2>/dev/null || echo "default")

echo "☸️ $CTX ($NS)"
