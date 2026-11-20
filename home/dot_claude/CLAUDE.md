# Global notes

## Git workflow
- When committing, use short, terse commit messages that follow the style of the repo's recent commits (check `git log --oneline`). No attribution.
- PR descriptions have three short sections: Why, What changed, and Verification (what was run or checked, with results).

## Dotfiles
- Dotfiles are managed with chezmoi (source: `~/.local/share/chezmoi`, repo `stianthaulow/dotfiles`). After changing a managed file, `chezmoi add` it, then ask me before committing and pushing from the source dir.

## Privileged commands
- When I ask you to run something with sudo, use `pkexec` instead of `sudo` (e.g. `pkexec pacman -S foo`).
- Exception: if I'm logged in over SSH (`$SSH_CONNECTION` or `$SSH_TTY` is set), pkexec won't work since there's no graphical polkit agent. Use `sudo` instead, and if it needs a password, give me the command to run myself.

## Desktop "b"
- `b` is my main home desktop (Omarchy, Ryzen 7950X3D, RTX 3090, user `stian`, home at `/home/stian`). From this laptop, reach it with `ssh b` (Tailscale SSH via MagicDNS, keyless). Run checks with `ssh b '<cmd>'` and copy files with `scp`/`rsync b:<path> <dest>`. Code lives in `~/Code`. sudo on b needs a password, so give me the command to run myself. If b is unreachable it's probably suspended; say so rather than retrying.

## Communication
- Never hand me a check you could run yourself. Run it and tell me the result.
- Never refer to plan steps, options, or items by number or label alone ("step 5", "option B", "$1", "#3"). Always restate what you mean as a short, terse full sentence.
