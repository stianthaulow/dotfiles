#!/usr/bin/env bash
set -euo pipefail

# Skip if gh already installed.
if command -v gh >/dev/null 2>&1; then
  echo "gh already installed, skipping."
  exit 0
fi

# Ensure curl & gnupg (for key import)
sudo apt-get update -y
sudo apt-get install -y curl ca-certificates gnupg

# Install GitHub CLI apt repo keyring (apt-key is deprecated)
sudo install -d -m 0755 /usr/share/keyrings
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
  | sudo tee /usr/share/keyrings/githubcli-archive-keyring.gpg >/dev/null
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg

# Add the repo (stable channel)
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
  | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null

# Install gh
sudo apt-get update -y
sudo apt-get install -y gh

# Quick sanity check
gh --version || { echo "gh did not install correctly"; exit 1; }
