#!/usr/bin/env bash
echo "Installing packages..."

echo "console-data console-data/keymap/policy select Select keymap from full list" | debconf-set-selections
echo "console-data console-data/keymap/full select No layout" | debconf-set-selections


DEBIAN_FRONTEND=noninteractive sudo apt-get -yq install \
git \
curl \
console-data \
fuse \
libfuse2 \
unzip \
tmux \
zsh

# Install oh-my-posh if not installed
if ! command -v oh-my-posh &> /dev/null; then
    curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin
fi

# Install latest neovim if not installed
if ! command -v nvim &> /dev/null; then
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
    chmod u+x nvim.appimage
    mv nvim.appimage ~/.local/bin/nvim
fi

if command -v gnome-shell >/dev/null 2>&1; then
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    gsettings set org.gnome.desktop.background picture-uri-dark file:///$HOME/Theme/Wallpaper/wallpaper.jpg
fi


if [[ $SHELL != */zsh ]]; then
    echo "Changing shell to zsh..."
    chsh -s /bin/zsh
fi