#!/bin/sh

if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

if [ -f "/etc/arch-release" ]; then
    sudo pacman -S --noconfirm git chezmoi
else
    DEBIAN_FRONTEND=noninteractive sudo apt-get -yq install git
    sh -c "$(curl -fsLS get.chezmoi.io/lb)"
fi

chezmoi init --apply stianthaulow