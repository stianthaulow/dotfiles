#!/usr/bin/env bash
echo "Installing packages..."

# Preseed console-data config
echo "console-data console-data/keymap/policy select Select keymap from arch list" | sudo debconf-set-selections
echo "console-data console-data/keymap/qwerty/layout select NO" | sudo debconf-set-selections
echo "console-data console-data/keymap/family select qwerty" | sudo debconf-set-selections

DEBIAN_FRONTEND=noninteractive sudo apt-get -yq install \
git \
curl \
console-data \
fuse \
libfuse2 \
unzip \
tmux \
lsd \
bat \
build-essential

# Install latest neovim if not installed
if ! command -v nvim &> /dev/null; then
    curl -LOs https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
    chmod u+x nvim.appimage
    sudo mv nvim.appimage /usr/local/bin/nvim
fi

if command -v gnome-shell >/dev/null 2>&1; then
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    gsettings set org.gnome.desktop.background picture-uri-dark file:///$HOME/Theme/Wallpaper/wallpaper.jpg
fi