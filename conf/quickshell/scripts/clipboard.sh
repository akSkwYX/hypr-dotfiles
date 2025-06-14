#!/usr/bin/env bash

chosen_item=$(cliphist list | fuzzel --dmenu --placeholder='Type to search clipboard')
if [[ -n "$chosen_item" ]]; then
   printf '%s' "$chosen_item" | cliphist decode | wl-copy
fi
