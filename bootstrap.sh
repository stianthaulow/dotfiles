#!/bin/sh
DEBIAN_FRONTEND=noninteractive apt-get -yq install git
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply stianthaulow
