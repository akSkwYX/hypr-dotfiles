#!/usr/bin/env bash

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

chosen_item=$(
  cat "${script_dir}/data/emojis.txt" \
  | fuzzel --dmenu --placeholder='Type to search emojis'
)

if [[ -n "$chosen_item" ]]; then
  printf '%s' "$chosen_item" \
    | cut -d ' ' -f1 \
    | tr -d '\n' \
    | wl-copy
fi
