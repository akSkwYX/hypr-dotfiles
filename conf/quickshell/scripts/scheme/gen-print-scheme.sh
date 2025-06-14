#!/usr/bin/env bash
set -euo pipefail

# Determine script directory
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/../util.sh"

# Determine input image: first arg if it exists & is a file; otherwise use last thumbnail
if [[ -n "${1:-}" && -f "$1" ]]; then
  img="$(realpath "$1")"
else
  img="$C_STATE/wallpaper/thumbnail.jpg"
fi

# If it's not already our thumbnail, generate one
if [[ "$img" != "$C_STATE/wallpaper/thumbnail.jpg" ]]; then
  thumb_dir="$C_CACHE/thumbnails"
  mkdir -p "$thumb_dir"
  hash="$(sha1sum "$img" | cut -d' ' -f1)"
  thumb_path="$thumb_dir/$hash.jpg"
  if [[ ! -f "$thumb_path" ]]; then
    magick -define jpeg:size=256x256 "$img" -thumbnail '128x128>' "$thumb_path"
  fi
  img="$thumb_path"
fi

# Define valid variants
variants=(vibrant tonalspot expressive fidelity fruitsalad rainbow neutral content monochrome)

# Pick variant: second arg if valid, else fall back to saved variant, else default to tonalspot
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

# Compute hash of the thumbnailed image
hash="$(sha1sum "$img" | cut -d' ' -f1)"
scheme_dir="$C_CACHE/schemes/$hash/$variant"

# Generate schemes if not cached
if [[ ! -d "$scheme_dir" ]]; then
  mkdir -p "$scheme_dir"
  colours=("$("$script_dir/score.py" "$img")")
  # autoadjust.py <mode> <variant> <colours...> <output_dir>
  "$script_dir/autoadjust.py" dark   "$variant" "${colours[@]}" "$scheme_dir"
  "$script_dir/autoadjust.py" light  "$variant" "${colours[@]}" "$scheme_dir"
fi

# Compute overall lightness to pick mode
lightness=$(magick "$img" -format '%[fx:int(mean*100)]' info:)
if (( lightness >= 60 )); then
  mode=light
else
  mode=dark
fi

# Output the chosen scheme file
cat "$scheme_dir/default/$mode.txt"
