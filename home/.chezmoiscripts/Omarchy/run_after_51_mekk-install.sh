#!/usr/bin/env bash
# Install deps for mekk's CLI and ~/.mekk (both chezmoi externals) when the lockfile is newer than the last install
set -eu

for dir in "$HOME/Projects/mekk" "$HOME/.mekk"; do
  [[ -f $dir/pnpm-lock.yaml ]] || continue
  [[ $dir/node_modules/.modules.yaml -nt $dir/pnpm-lock.yaml ]] && continue
  (cd "$dir" && mise exec node@22 -- pnpm install --frozen-lockfile --silent)
done
