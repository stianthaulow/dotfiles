#!/bin/bash

sudo pacman -S --needed --noconfirm \
zsh \
zsh-completions \
neovim

if [[ $SHELL != */zsh ]]; then
    chsh -s /usr/bin/zsh
fi