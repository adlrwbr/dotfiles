#!/bin/bash

# install delta-git: https://github.com/dandavison/delta

# zsh
ln -s /home/adler/dotfiles/.zshrc ~/.zshrc

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

ln -s /home/adler/dotfiles/hypr/hyprpaper.conf ~/.config/hypr/hyprpaper.conf
ln -s /home/adler/dotfiles/hypr/hyprland.conf ~/.config/hypr/hyprland.conf
ln -s /home/adler/dotfiles/swaylock/ ~/.config/swaylock
ln -s /home/adler/dotfiles/waybar/ ~/.config/waybar
ln -s /home/adler/dotfiles/kanshi/ ~/.config/kanshi
