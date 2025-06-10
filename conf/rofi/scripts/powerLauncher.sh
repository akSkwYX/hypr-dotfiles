#!/usr/bin/env bash

dir="$HOME/.config/rofi/powerLauncher"
theme='base'

entries="\n\n\n\n"

chosen=$(echo -e "$entries" \
          | rofi -dmenu \
                 -theme ${dir}/${theme}.rasi \
                 -p '' \
                 -lines 1 \
                 -columns 5 \
                 -no-custom \
                 -hide-scrollbar)

case "$chosen" in
   **) echo Power Off ;;
   **) echo Sleep ;;
   **) echo Hibernate ;;
   **) echo Lock ;;
   **) echo Exit ;;
esac
