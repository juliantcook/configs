#!/bin/bash

ln -s .myrc ~/.myrc
ln -s .tmux.conf ~/.tmux.conf
ln -s .gitconfig ~/.gitconfig

zshrc="${ZDOTDIR:-$HOME}/.zshrc"
source_line="source ~/.myrc"

if [ -e "$zshrc" ] && grep -Fxq "$source_line" "$zshrc"; then
  echo "$source_line already present in $zshrc"
else
  echo "$source_line" >> "$zshrc"
fi
