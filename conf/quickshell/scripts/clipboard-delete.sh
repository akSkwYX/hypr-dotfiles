#!/usr/bin/env bash

chosen_item=$(cliphist list | fuzzel --dmenu --prompt='del > ' --placeholder='Delete from clipboard')
if [[ -n "$chosen_item" ]]; then
    printf '%s' "$chosen_item" | cliphist delete
fi

