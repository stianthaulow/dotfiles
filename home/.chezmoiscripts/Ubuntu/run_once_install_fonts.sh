#!/bin/bash

if [ -d "${HOME}/.local/share/fonts/NerdFonts/JetBrainsMono" ]; then
  fc-cache -f "${HOME}/.local/share/fonts"
fi