#!/bin/bash

# kitty
ln -s ~/dotfiles/kitty/kitty.conf ~/.config/kitty/kitty.conf
ln -s ~/dotfiles/kitty/themes ~/.config/kitty/themes

# tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
ln -s ~/dotfiles/.tmux.conf ~/.tmux.conf

# nvim
ln -s /home/adler/dotfiles/nvim-vimscript ~/.config/nvim-vimscript
ln -s /home/adler/dotfiles/nvim ~/.config/nvim

# lvim
ln -s ~/dotfiles/lvim/config.lua ~/.config/lvim/config.lua

# touchegg
ln -s ~/dotfiles/touchegg.conf ~/.config/touchegg/
