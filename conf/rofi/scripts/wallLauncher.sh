#!/usr/bin/env bash

dir="${XDG_CONFIG_HOME:-$HOME/.config}/rofi/wallLauncher"
theme='base'

## Run
rofi \
    -show drun \
    -theme ${dir}/${theme}.rasi
