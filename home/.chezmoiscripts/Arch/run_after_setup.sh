#!/bin/bash

sudo pacman -S --needed --noconfirm \
zsh \
zsh-completions \
neovim

chsh -s /usr/bin/zsh
