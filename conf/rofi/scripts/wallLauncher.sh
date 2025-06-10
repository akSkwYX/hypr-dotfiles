#!/usr/bin/env bash

dir="$HOME/.config/rofi/wallLauncher"
theme='base'

## Run
rofi \
    -show drun \
    -theme ${dir}/${theme}.rasi
