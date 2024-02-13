#!/usr/bin/env bash
echo "Installing packages..."

DEBIAN_FRONTEND=noninteractive sudo apt-get -yq install \
git \
console-data \
zsh

loadkeys no

if command -v gnome-shell >/dev/null 2>&1; then
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    gsettings set org.gnome.desktop.background picture-uri-dark file:///$HOME/Theme/Wallpaper/wallpaper.jpg
fi
