#!/bin/bash

set -e

email="$1"
if [ -z "$email" ]; then
  echo "usage: $0 <email>" >&2
  exit 1
fi

ln -sfn $(pwd)/.myrc ~/.myrc
ln -sfn $(pwd)/.tmux.conf ~/.tmux.conf

# gitconfig is copied (not symlinked) so the email can differ per workspace
rm -f ~/.gitconfig
cp "$(pwd)/.gitconfig" ~/.gitconfig
git config --global user.email "$email"

zshrc="${ZDOTDIR:-$HOME}/.zshrc"
source_line="source ~/.myrc"

if [ -e "$zshrc" ] && grep -Fxq "$source_line" "$zshrc"; then
  echo "$source_line already present in $zshrc"
else
  echo "$source_line" >> "$zshrc"
fi
