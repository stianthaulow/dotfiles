#!/usr/bin/env bash
set -euo pipefail

sudo apt-get install -y curl unzip

curl -fsSL https://fnm.vercel.app/install | bash