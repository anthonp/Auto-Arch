#!/bin/bash

export PATH=$PATH:~/.local/bin
cp -r $HOME/Auto-Arch/dotfiles/* $HOME/.config/
pip install konsave
konsave -i $HOME/Auto-Arch/kde.knsv
sleep 1
konsave -a kde
