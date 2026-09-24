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

# Raycast doesn't load the zsh config, so run the zsh git-check-all function
# itself (one implementation), after 01-env.zsh sets PROJECT_ROOTS (default +
# any ~/.zshrc.local override).
CONF="$(cd "$(dirname "$0")" && pwd -P)/../zsh/conf.d"
if [ ! -f "$CONF/01-env.zsh" ]; then
    echo "Can't find $CONF/01-env.zsh: run this script from the dotfiles raycast/ folder (install.sh links it)"
    exit 1
fi
# shellcheck disable=SC2016  # $1 is expanded by zsh
zsh -f -c 'source "$1/01-env.zsh" >/dev/null 2>&1; source "$1/05-functions.zsh"; git-check-all' _ "$CONF"
