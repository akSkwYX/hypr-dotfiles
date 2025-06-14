#!/usr/bin/env bash
set -euo pipefail

# Internal helper: print with colour, level tag, and message
_out() {
  local colour_code level text
  colour_code="$1"; level="$2"; text="$3"; shift 3
  # Set colour
  printf '\e[%sm' "$colour_code"
  # Print any extra args, then the level and text
  if [[ $# -gt 0 ]]; then
    printf '%s ' "$@"
  fi
  printf ':: [%s] %s\n' "$level" "$text"
  # Reset colour
  printf '\e[0m'
}

# Public logging functions
log()   { _out 36 LOG "$1" "${@:2}"; }    # cyan (36)
warn()  { _out 33 WARN "$1" "${@:2}"; }   # yellow (33)
error() { _out 31 ERROR "$1" "${@:2}"; return 1; }  # red (31)
input() { _out 34 INPUT "$1" "${@:2}"; }  # blue (34)

# Read a key from JSON config, falling back to data/config.json if unset/null
get_config() {
  local key value fallback_file
  key="$1"
  fallback_file="$(dirname "${BASH_SOURCE[0]}")/data/config.json"
  if [[ -f "${C_CONFIG_FILE:-}" ]]; then
    value="$(jq -r --arg k "$key" '.[$k]' "$C_CONFIG_FILE")"
  fi
  if [[ -n "${value:-}" && "$value" != "null" ]]; then
    printf '%s\n' "$value"
  else
    jq -r --arg k "$key" '.[$k]' "$fallback_file"
  fi
}

# Write a key/value to JSON config, preserving existing keys
set_config() {
  local key value tmp
  key="$1"; value="$2"
  mkdir -p "$(dirname "${C_CONFIG_FILE}")"
  if [[ -f "${C_CONFIG_FILE}" ]]; then
    tmp="$(mktemp)"
    cp "$C_CONFIG_FILE" "$tmp"
    if ! jq --arg k "$key" --argjson v "$value" '.[$k]=$v' "$tmp" > "$C_CONFIG_FILE"; then
      cp "$tmp" "$C_CONFIG_FILE"
    fi
    rm -f "$tmp"
  else
    # Create new JSON with just this key
    echo '{}' | jq --arg k "$key" --argjson v "$value" '.[$k]=$v' > "$C_CONFIG_FILE"
  fi
}

# Set up XDG-based directories (with sensible defaults)
: "${XDG_DATA_HOME:=$HOME/.local/share}"
: "${XDG_STATE_HOME:=$HOME/.local/state}"
: "${XDG_CACHE_HOME:=$HOME/.cache}"
: "${XDG_CONFIG_HOME:=$HOME/.config}"

C_DATA="$XDG_DATA_HOME/quickshell"
C_STATE="$XDG_STATE_HOME/quickshell"
C_CACHE="$XDG_CACHE_HOME/quickshell"
CONFIG="$XDG_CONFIG_HOME"
C_CONFIG="$CONFIG/quickshell"
C_CONFIG_FILE="$C_CONFIG/scripts.json"

# Ensure directories exist
mkdir -p "$C_DATA" "$C_STATE" "$C_CACHE" "$C_CONFIG"
