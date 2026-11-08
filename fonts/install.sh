#!/bin/zsh

source ../zsh/lib/prun.zsh
source ../zsh/lib/os.zsh

if is_mac; then
  prun mkdir -p ~/Library/Fonts
  for f in `pwd`/*.ttf; do
    prun cp -f $f ~/Library/Fonts
  done
else
  prun mkdir -p ~/.fonts
  for f in `pwd`/*.ttf; do
    prun ln -sf $f ~/.fonts
  done
fi
