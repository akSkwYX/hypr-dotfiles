#!/usr/bin/env bash
set -euo pipefail

# Source shared utilities
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/../util.sh"

# Move a client matching a jq selector into a special workspace
move_client() {
  local selector="$1"
  local workspace="$2"

  # If the client isn't already in special:<workspace>
  if ! hyprctl -j clients \
       | jq -e --arg sel "$selector" --arg ws "special:$workspace" \
           'first(.[] | select(eval($sel))).workspace.name == $ws' \
           >/dev/null; then

    # Get its address and move it silently
    local addr
    addr=$(hyprctl -j clients \
            | jq -r --arg sel "$selector" \
               'first(.[] | select(eval($sel))).address')
    hyprctl dispatch movetoworkspacesilent "special:$workspace,address:$addr"
  fi
}

# Spawn a client if none matches the jq selector
spawn_client() {
  local selector="$1"
  local spawn_cmd="$2"

  if ! hyprctl -j clients \
       | jq -e --arg sel "$selector" 'first(.[] | select(eval($sel)))' \
           >/dev/null; then
    # Not running: spawn it
    eval "app2unit -- $spawn_cmd & disown"
    return 0
  fi

  # Already exists
  return 1
}

# Apply a jq operation to a JSON string stored in a variable
jq_var() {
  local op="$1"
  local json="$2"
  jq -nr --argjson data "$json" '$data | '"$op"
}

# Toggle a special workspace by spawning/moving its apps, then switching to it
toggle_workspace() {
  local workspace="$1"
  # Load the array of apps from config (expects JSON array)
  local apps
  apps="$(get-config "toggles.${workspace}.apps")"

  # Iterate indices 0..length-1
  local length i app action selector extra_cond spawn_cmd
  length=$(jq_var 'length' "$apps")
  for (( i=0; i<length; i++ )); do
    app=$(jq_var ".[$i]" "$apps")
    action=$(jq_var '.action' "$app")
    selector=$(jq_var '.selector' "$app")
    extra_cond=$(jq_var '.extraCond // true' "$app")

    # Only proceed if extraCond is true
    if eval "[[ $extra_cond == true ]]"; then
      if [[ $action == spawn* ]]; then
        spawn_cmd=$(jq_var '.spawn' "$app")
        spawn_client "$selector" "$spawn_cmd" || true
      fi
      if [[ $action == move* ]]; then
        move_client "$selector" "$workspace"
      fi
    fi
  done

  # Finally, switch to the special workspace
  hyprctl dispatch togglespecialworkspace "$workspace"
}

# Entry point: pass all script args to toggle_workspace
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  if [[ $# -ne 1 ]]; then
    echo "Usage: $(basename "$0") <workspace>" >&2
    exit 1
  fi
  toggle_workspace "$1"
fi
