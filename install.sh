#!/bin/bash

# kitty
ln -s ~/dotfiles/kitty/kitty.conf ~/.config/kitty/kitty.conf
ln -s ~/dotfiles/kitty/themes ~/.config/kitty/themes

# tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
ln -s ~/dotfiles/.tmux.conf ~/.tmux.conf

# nvim
ln -s ~/dotfiles/nvim/* ~/.config/nvim/
