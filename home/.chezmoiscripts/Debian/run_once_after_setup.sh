#!/usr/bin/env bash
echo "Installing packages..."

DEBIAN_FRONTEND=noninteractive sudo apt-get -yq install \
git \
curl \
console-data \
fuse \
libfuse2 \
unzip \
zsh

curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin

# Install latest neovim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod u+x nvim.appimage
mv nvim.appimage ~/.local/bin/nvim

sudo loadkeys no

if command -v gnome-shell >/dev/null 2>&1; then
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    gsettings set org.gnome.desktop.background picture-uri-dark file:///$HOME/Theme/Wallpaper/wallpaper.jpg
fi


if [[ $SHELL != */zsh ]]; then
    chsh -s /bin/zsh
fi