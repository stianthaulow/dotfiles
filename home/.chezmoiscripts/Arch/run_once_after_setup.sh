#!/bin/bash

echo "Syncing packages..."
sudo pacman --sync --needed --quiet --noconfirm \
zsh \
zsh-completions \
neovim \
2> >(grep -v 'is up to date' >&2)

if [[ $SHELL != */zsh ]]; then
    chsh -s /usr/bin/zsh
fi
