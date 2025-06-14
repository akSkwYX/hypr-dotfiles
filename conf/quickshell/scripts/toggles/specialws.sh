#!/usr/bin/env bash
set -euo pipefail

# Check if there is any workspace literally named "special:special"
if ! hyprctl workspaces -j \
     | jq -e 'first(.[] | select(.name == "special:special"))' >/dev/null; then

  # No such workspace exists, so toggle relative to the current one
  activews=$(hyprctl activewindow -j | jq -r '.workspace.name')

  if [[ $activews =~ ^special: ]]; then
    # If the current workspace is special:XYZ, strip off the "special:" prefix
    togglews=${activews#special:}
  else
    # Otherwise, use the generic "special"
    togglews="special"
  fi

else
  # A workspace named "special:special" already exists, so just use "special"
  togglews="special"
fi

# Tell Hyprland to toggle that “special” workspace
hyprctl dispatch togglespecialworkspace "$togglews"
