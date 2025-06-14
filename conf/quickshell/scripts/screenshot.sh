#!/usr/bin/env bash
set -euo pipefail

# Source shared utilities (logging, error, etc.)
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/util.sh"

# Ensure screenshot cache directory exists
mkdir -p "$C_CACHE/screenshots"
tmp_file="$C_CACHE/screenshots/$(date +%Y%m%d%H%M%S)"

# If called with “region” mode
if [[ "${1:-}" == "region" ]]; then
  # Optional “freeze” arg: grab the screen and hide cursor
  if [[ "${2:-}" == "freeze" ]]; then
    wayfreeze --hide-cursor & 
    PID=$!
    disown
    sleep 0.1
  fi

  # Get active workspace ID
  ws=$(hyprctl -j activeworkspace | jq -r '.id')

  # Compute region of all windows on that workspace, and let user refine/select with slurp
  region=$(
    hyprctl -j clients \
      | jq -r --argjson ws "$ws" '
          .[] 
          | select(.workspace.id == $ws) 
          | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"
        ' \
      | slurp
  )

  if [[ -n "$region" ]]; then
    # Capture that region and pipe into swappy for annotation
    grim -l 0 -g "$region" - | swappy -f - &
    disown
  fi

  # If we froze the screen grab, kill the helper process
  if [[ -n "${PID-:-}" ]]; then
    kill "$PID"
  fi

  exit 0
fi

# Default mode: fullscreen or specified args
grim "$@" "$tmp_file" && wl-copy < "$tmp_file" || exit 1

# Send notification with “open” and “save” actions, capturing which was clicked
action=$(notify-send \
  -i image-x-generic-symbolic \
  -h "STRING:image-path:$tmp_file" \
  -a caelestia-screenshot \
  --action=open=Open \
  --action=save=Save \
  'Screenshot taken' "Saved to $tmp_file and copied to clipboard" \
  -p)

case "$action" in
  open)
    # Open in swappy for annotation
    swappy -f "$tmp_file" &
    disown
    ;;
  save)
    # Ask for save location
    save_file=$(zenity --file-selection --save --title='Save As')
    if [[ -z "$save_file" ]]; then
      exit 0
    fi
    if [[ -f "$save_file" ]]; then
      # Confirm overwrite
      if ! yad \
           --image=abrt \
           --title='Warning!' \
           --text='<span size="x-large">Overwrite existing file?</span>' \
           --buttons-layout='center' \
           --borders=20 \
           --button=gtk-cancel:1 \
           --button=gtk-ok:0; then
        exit 0
      fi
    fi
    cp "$tmp_file" "$save_file"
    ;;
  *)
    # No action or unrecognized
    ;;
esac
