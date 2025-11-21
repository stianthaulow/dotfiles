#!/usr/bin/env bash
set -euo pipefail

if ! command -v cargo >/dev/null 2>&1; then
  echo "cargo not found; install Rust via rustup before running this script." >&2
  exit 1
fi

workdir="$(mktemp -d)"
trap 'rm -rf "$workdir"' EXIT

git clone --depth 1 https://github.com/sxyazi/yazi.git "$workdir/yazi"
pushd "$workdir/yazi" >/dev/null
cargo build --release --locked
sudo install -m 755 target/release/yazi /usr/local/bin/yazi
sudo install -m 755 target/release/ya /usr/local/bin/ya
popd >/dev/null

echo "Yazi installed to /usr/local/bin"
