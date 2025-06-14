#!/usr/bin/env bash
set -euo pipefail

# Determine this script’s directory
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default flags
flag_help=false
flag_daemon=false

# Parse options
while getopts "hd-:" opt; do
  case "$opt" in
    h) flag_help=true ;;
    d) flag_daemon=true ;;
    -)
      case "${OPTARG}" in
        help) flag_help=true ;;
        daemon) flag_daemon=true ;;
        *) echo "Unknown option --${OPTARG}" >&2; exit 1 ;;
      esac
      ;;
    *) exit 1 ;;
  esac
done
shift $((OPTIND-1))

if [[ "$flag_help" == true ]]; then
  cat <<EOF
Usage:
    caelestia pip ( -h | --help )
    caelestia pip [ -d | --daemon ]

Options:
    -h, --help        Print this help message and exit
    -d, --daemon      Run this script in daemon mode

Normal mode (no args):
    Move and resize the active window to picture-in-picture default geometry.

Daemon mode:
    Set all picture-in-picture window initial geometry to default.
EOF
  exit 0
fi

# Source logging/utilities
source "$script_dir/util.sh"

# Function to resize & move a window by its hyprland address and workspace
handle_window() {
  local address="$1"
  local workspace="$2"

  # Get the monitor ID of that workspace
  local monitor_id
  monitor_id=$(
    hyprctl workspaces -j \
    | jq -r --arg ws "$workspace" '.[] 
        | select(.name == $ws).monitorID'
  )

  # Get monitor resolution: width height
  local mon_w mon_h
  read -r mon_w mon_h < <(
    hyprctl monitors -j \
    | jq -r --argjson id "$monitor_id" '.[] 
        | select(.id == $id) 
        | "\(.width) \(.height)"'
  )

  # Get window size: width height
  local win_w win_h
  read -r win_w win_h < <(
    hyprctl clients -j \
    | jq -r --arg addr "$address" '.[] 
        | select(.address == $addr).size[]'
  )

  # Calculate scaled size: width/height scaled to quarter-monitor height
  # scale_factor = (mon_h / 4) / win_h
  local scale_factor
  scale_factor=$(awk "BEGIN { printf \"%.6f\", ($mon_h/4)/$win_h }")

  local new_w new_h
  new_w=$(awk "BEGIN { printf \"%d\", $win_w * $scale_factor }")
  new_h=$(awk "BEGIN { printf \"%d\", $win_h * $scale_factor }")

  # Resize
  hyprctl dispatch "resizewindowpixel exact ${new_w},${new_h},address:$address" >/dev/null

  # Move to bottom-right corner with a small margin
  local x y
  x=$(awk "BEGIN { printf \"%d\", $mon_w - $new_w - ($mon_w*0.02) }")
  y=$(awk "BEGIN { printf \"%d\", $mon_h - $new_h - ($mon_h*0.03) }")
  hyprctl dispatch "movewindowpixel exact $x $y,address:$address" >/dev/null

  log "Handled window at address $address"
}

if [[ "$flag_daemon" == true ]]; then
  log "Daemon started"
  socat -U - UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" \
    | while IFS= read -r line; do
        case "$line" in
          openwindow*)
            # extract fields: address, workspace, class...
            IFS=',' read -r _ addr ws _ <<<"${line#openwindow }"
            # only picture-in-picture windows
            if [[ "$ws" =~ ^(Picture(-| )in(-| )Picture)$ ]]; then
              handle_window "0x$addr" "$ws"
            fi
            ;;
        esac
      done
  exit 0
fi

# Normal mode: resize the currently focused (active) window if floating
mapfile -t active_info < <(
  hyprctl activewindow -j \
  | jq -r '"\(.address)\n\(.workspace.name)\n\(.floating)"'
)

if [[ "${active_info[2]}" == "true" ]]; then
  handle_window "${active_info[0]}" "${active_info[1]}"
else
  warn "Focused window is not floating, ignoring"
fi
