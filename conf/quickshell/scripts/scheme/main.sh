#!/usr/bin/env bash
set -euo pipefail

# Source shared utilities (logging functions, get-config, etc.)
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/util.sh"

# Helper: check if an element is in an array
contains_element() {
  local match="$1"; shift
  for el in "$@"; do
    [[ "$el" == "$match" ]] && return 0
  done
  return 1
}

# Helper: pick a random element from an array
random_choice() {
  local arr=("$@")
  printf '%s\n' "${arr[RANDOM % ${#arr[@]}]}"
}

# Persist a scheme selection
set_scheme() {
  local path="$1" name="$2" mode="$3"
  mkdir -p "$C_STATE/scheme"
  cp "$path" "$C_STATE/scheme/current.txt"
  printf '%s' "$name" >"$C_STATE/scheme/current-name.txt"
  printf '%s' "$mode" >"$C_STATE/scheme/current-mode.txt"
  log "Changed scheme to $name ($mode)"
}

# Locate schemes directory and list of valid schemes
schemes_dir="$script_dir/data/schemes"
mapfile -t valid_schemes < <(find "$schemes_dir" -maxdepth 1 -mindepth 1 -type d -printf '%f\n')

# Read positional args
scheme_arg="${1:-}"
flavour_arg="${2:-}"
mode_arg="${3:-}"

# If no scheme provided, pick one at random
if [[ -z "$scheme_arg" ]]; then
  scheme_arg="$(random_choice "${valid_schemes[@]}")"
fi

# Validate scheme
if ! contains_element "$scheme_arg" "${valid_schemes[@]}"; then
  error "Invalid scheme: $scheme_arg"
  exit 1
fi

scheme_path="$schemes_dir/$scheme_arg"

# Gather flavours (subdirectories) and modes (direct .txt files)
mapfile -t flavours < <(find "$scheme_path" -mindepth 1 -maxdepth 1 -type d -printf '%f\n')
mapfile -t modes    < <(find "$scheme_path" -mindepth 1 -maxdepth 1 -type f -name '*.txt' -printf '%f\n' | sed 's/\.txt$//')

if (( ${#modes[@]} > 0 )); then
  # No flavour directories: treat $flavour_arg as mode
  mode="$flavour_arg"
  if [[ -z "$mode" ]]; then
    # Try current mode, else random
    mode="$(<"$C_STATE/scheme/current-mode.txt" 2>/dev/null || true)"
    if ! contains_element "$mode" "${modes[@]}"; then
      mode="$(random_choice "${modes[@]}")"
    fi
  fi
  if contains_element "$mode" "${modes[@]}"; then
    set_scheme "$scheme_path/$mode.txt" "$scheme_arg" "$mode"
  else
    error "Invalid mode for $scheme_arg: $mode"
    exit 1
  fi

else
  # Multiple flavours exist: treat $flavour_arg as flavor
  if [[ -z "$flavour_arg" ]]; then
    flavour_arg="$(random_choice "${flavours[@]}")"
  fi
  if ! contains_element "$flavour_arg" "${flavours[@]}"; then
    error "Invalid flavour for $scheme_arg: $flavour_arg"
    exit 1
  fi

  flavour_path="$scheme_path/$flavour_arg"
  mapfile -t modes < <(find "$flavour_path" -maxdepth 1 -type f -name '*.txt' -printf '%f\n' | sed 's/\.txt$//')

  mode="$mode_arg"
  if [[ -z "$mode" ]]; then
    mode="$(<"$C_STATE/scheme/current-mode.txt" 2>/dev/null || true)"
    if ! contains_element "$mode" "${modes[@]}"; then
      mode="$(random_choice "${modes[@]}")"
    fi
  fi
  if contains_element "$mode" "${modes[@]}"; then
    set_scheme "$flavour_path/$mode.txt" "$scheme_arg-$flavour_arg" "$mode"
  else
    error "Invalid mode for $scheme_arg $flavour_arg: $mode"
    exit 1
  fi
fi
