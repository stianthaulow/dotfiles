#!/usr/bin/env bash
set -eu

PACKAGES_TO_INSTALL=(
  bitwarden
)

missing=()
for pkg in "${PACKAGES_TO_INSTALL[@]}"; do
  if ! yay -Qq "$pkg" &>/dev/null; then
    missing+=("$pkg")
  fi
done

if ((${#missing[@]})); then
  echo "Installing: ${missing[*]}"
  yay -S --noconfirm --needed -- "${missing[@]}"
fi