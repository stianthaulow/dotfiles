#!/bin/sh
if [ -f "/etc/arch-release" ]; then
    pacman -S --noconfirm git chezmoi
    
else
    DEBIAN_FRONTEND=noninteractive apt-get -yq install git
    sh -c "$(curl -fsLS get.chezmoi.io)"
fi

~/bin/chezmoi init --apply stianthaulow