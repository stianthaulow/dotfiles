#!/usr/bin/env bash
set -eu

if [ -d "${HOME}/.local/share/fonts/NerdFonts/JetBrainsMono" ]; then
  fc-cache -f "${HOME}/.local/share/fonts"
fi