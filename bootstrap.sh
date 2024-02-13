#!/bin/sh


localbin="${HOME}/.local/bin"
if [ ! -d "$localbin" ]; then
    mkdir -p "$dir"
    PATH="$localbin:$PATH"
fi

if [ -f "/etc/arch-release" ]; then
    sudo pacman -S --noconfirm git chezmoi
else
    DEBIAN_FRONTEND=noninteractive sudo apt-get -yq install git
    sh -c "$(curl -fsLS get.chezmoi.io/lb)"
fi

chezmoi init --apply stianthaulow