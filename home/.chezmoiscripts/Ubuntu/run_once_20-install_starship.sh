#!/usr/bin/env bash
set -eu

if ! command -v starship >/dev/null 2>&1; then
  echo "Installing Starship prompt..."
  curl -sS https://starship.rs/install.sh | sh -s -- -y
fi
