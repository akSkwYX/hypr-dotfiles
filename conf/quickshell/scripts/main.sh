#!/usr/bin/env bash

# Determine the directory this script lives in
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source utility functions
# Assumes util.sh is the Bash equivalent of util.fish
# You may need to port any Fish-specific functions into util.sh first
# and make sure it’s executable.
source "$script_dir/util.sh"

cmd="$1"
shift || true

case "$cmd" in
  shell)
    # No extra args: start the shell if it isn’t already running
    if [[ $# -eq 0 ]]; then
      if qs list --all | grep -q "Config path: $C_DATA/shell/shell.qml"; then
        warn "Shell already running"
      else
        "$C_DATA/shell/run.sh"
      fi

    # “help”: show IPC commands
    elif [[ "$1" == "help" ]]; then
      qs -p "$C_DATA/shell" ipc show
      exit 0

    # Any other arg: send it as an IPC call, if shell is up
    else
      if qs list --all | grep -q "Config path: $C_DATA/shell/shell.qml"; then
        qs -p "$C_DATA/shell" ipc call "$@"
      else
        warn "Shell unavailable"
      fi
    fi
    ;;

  toggle)
    valid=(communication music sysmon specialws todo)
    if printf '%s\n' "${valid[@]}" | grep -qx "$1"; then
      if [[ "$1" == "specialws" ]]; then
        "$script_dir/toggles/specialws.sh"
      else
        source "$script_dir/toggles/util.sh"
        toggle-workspace "$1"
      fi
    else
      error "Invalid toggle: $1"
    fi
    ;;

  workspace-action)
    "$script_dir/workspace-action.sh" "$@"
    ;;

  scheme)
    if [[ "$1" == "print" ]]; then
      shift
      "$script_dir/scheme/gen-print-scheme.sh" "$@"
    else
      "$script_dir/scheme/main.sh" "$@"
    fi
    ;;

  variant)
    variants=(vibrant tonalspot expressive fidelity fruitsalad rainbow neutral content monochrome)
    if printf '%s\n' "${variants[@]}" | grep -qx "$1"; then
      echo -n "$1" > "$C_STATE/scheme/current-variant.txt"
      "$script_dir/scheme/gen-scheme.sh"
    else
      error "Invalid variant: $1"
    fi
    ;;

  install)
    modules=(scripts btop discord firefox fish foot fuzzel hypr safeeyes shell slurp spicetify gtk qt vscode)
    if [[ "$1" == "all" ]]; then
      shift
      for m in "${modules[@]}"; do
        "$script_dir/install/$m.sh" "$@"
      done
    elif printf '%s\n' "${modules[@]}" | grep -qx "$1"; then
      "$script_dir/install/$1.sh" "${@:2}"
    else
      error "Invalid module: $1"
    fi
    # Ensure a color scheme is initialized after installs
    if [[ ! -f "$C_STATE/scheme/current.txt" ]]; then
      "$script_dir/scheme/main.sh" onedark
    fi
    ;;

  screenshot|record|clipboard|clipboard-delete|emoji-picker|wallpaper|pip)
    "$script_dir/$cmd.sh" "$@"
    ;;

  help|"" )
    cat <<EOF
Usage: $(basename "$0") COMMAND [ ...args ]

COMMAND := help | install | shell | toggle | workspace-action | scheme | variant | \
screenshot | record | clipboard | clipboard-delete | emoji-picker | wallpaper | pip

  help              Show this help message
  install           Install a module
  shell             Start the shell or send it an IPC message
  toggle            Toggle a special workspace (communication, music, sysmon, specialws, todo)
  workspace-action  Execute a Hyprland workspace dispatcher
  scheme            Change the current colour scheme (or print it)
  variant           Switch the current scheme variant
  screenshot        Take a screenshot
  record            Take a screen recording
  clipboard         Open clipboard history
  clipboard-delete  Delete an entry from clipboard history
  emoji-picker      Open the emoji picker
  wallpaper         Change the wallpaper
  pip               Toggle picture-in-picture mode for the focused window
EOF
    ;;

  *)
    error "Unknown command: $cmd"
    ;;
esac

# Exit with success if the user asked for help
if [[ "$cmd" == "help" ]]; then
  exit 0
else
  exit 1
fi
