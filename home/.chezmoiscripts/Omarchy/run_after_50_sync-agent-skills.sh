#!/usr/bin/env bash
# Relink agent skills from dotfiles-private (pulled as a chezmoi external) on every apply
set -eu

sync=$HOME/.local/share/dotfiles-private/bin/agent-skills
[[ -x $sync ]] || exit 0
"$sync" sync --quiet
