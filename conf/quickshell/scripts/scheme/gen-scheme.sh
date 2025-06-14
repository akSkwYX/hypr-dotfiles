#!/usr/bin/env bash
set -euo pipefail

# Determine script directory
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/../util.sh"

# Determine input image: first arg if file, else use last wallpaper thumbnail
if [[ -n "${1:-}" && -f "$1" ]]; then
  img="$(realpath "$1")"
else
  img="$C_STATE/wallpaper/thumbnail.jpg"
fi

# Valid scheme variants
variants=(vibrant tonalspot expressive fidelity fruitsalad rainbow neutral content monochrome)

# Pick variant: second arg if valid, else fallback to saved, else tonalspot
if [[ -n "${2:-}" ]] && printf '%s\n' "${variants[@]}" | grep -qx "$2"; then
  variant="$2"
else
  if [[ -f "$C_STATE/scheme/current-variant.txt" ]]; then
    variant="$(<"$C_STATE/scheme/current-variant.txt")"
  else
    variant="tonalspot"
  fi
  if ! printf '%s\n' "${variants[@]}" | grep -qx "$variant"; then
    variant="tonalspot"
  fi
fi

# Compute hash of the image path
hash="$(sha1sum <<<"$img" | cut -d' ' -f1)"
cache_dir="$C_CACHE/schemes/$hash/$variant"

# Generate and cache schemes if missing
if [[ ! -d "$cache_dir" ]]; then
  mkdir -p "$cache_dir"
  # score.py outputs color list on one line or multiple; capture as args
  IFS=$'\n' read -r -d '' -a colours < <("$script_dir/score.py" "$img" && printf '\0')
  # Generate dark and light variants
  "$script_dir/autoadjust.py" dark   "$variant" "${colours[@]}" "$C_CACHE/schemes/$hash"
  "$script_dir/autoadjust.py" light  "$variant" "${colours[@]}" "$C_CACHE/schemes/$hash"
fi

# Copy cached scheme into data/schemes/dynamic
dynamic_dir="$script_dir/../data/schemes/dynamic"
rm -rf "$dynamic_dir"
cp -r "$cache_dir" "$dynamic_dir"

# If current scheme is dynamic-<variant>, reapply it
if [[ -f "$C_STATE/scheme/current-name.txt" ]]; then
  current_name="$(<"$C_STATE/scheme/current-name.txt")"
  if [[ "$current_name" =~ ^dynamic-(.+)$ ]]; then
    sel_variant="${BASH_REMATCH[1]}"
    scheme_path="$dynamic_dir/$sel_variant"
    # Fallback to default if missing
    if [[ ! -d "$scheme_path" ]]; then
      sel_variant="default"
    fi
    # Apply scheme: pass MODE through environment
    MODE="${MODE:-}" "$script_dir/main.fish" dynamic "$sel_variant" "$MODE" >/dev/null
  fi
fi
