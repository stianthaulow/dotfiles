#!/bin/sh
if [ -f "/etc/arch-release" ]; then
    sudo pacman -S --noconfirm git chezmoi
    chezmoi init --apply stianthaulow
else
    DEBIAN_FRONTEND=noninteractive sudo apt-get -yq install git
    sh -c "$(curl -fsLS get.chezmoi.io)"
    ~/bin/chezmoi init --apply stianthaulow
fi