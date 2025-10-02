#!/usr/bin/env bash
set -eu

PACKAGES_TO_REMOVE=(
  1password-beta
  1password-cli
  signal-desktop
)

installed=()
for pkg in "${PACKAGES_TO_REMOVE[@]}"; do
  if yay -Qq "$pkg" &>/dev/null; then
    installed+=("$pkg")
  fi
done

if ((${#installed[@]})); then
  echo "Removing packages..."
  yay -Rns --noconfirm -- "${installed[@]}"
fi