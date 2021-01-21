#!/bin/bash

# Install zsh if not installed
if [ $(dpkg-query -W -f='${Status}' zsh 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
    sudo apt-get install -y zsh
fi

if [ ! -d ~/.oh-my-zsh ]; then
    sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

    # Link .zshrc
    ln -s ~/dotfiles/.zshrc ~/.zshrc
fi
