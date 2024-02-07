#!/bin/sh
if [ -f "/etc/arch-release" ]; then
    pacman -S --noconfirm git chezmoi
    exec chezmoi init --apply stianthaulow
else
    DEBIAN_FRONTEND=noninteractive apt-get -yq install git
    sh -c "$(curl -fsLS get.chezmoi.io)"
    ~/bin/chezmoi init --apply stianthaulow
fi