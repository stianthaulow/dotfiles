#!/usr/bin/env bash
echo "Installing packages..."

DEBIAN_FRONTEND=noninteractive sudo apt-get -yq install git
DEBIAN_FRONTEND=noninteractive sudo apt-get -yq install console-data

loadkeys no

gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.background picture-uri-dark file:///$HOME/Theme/Wallpaper/wallpaper.jpg