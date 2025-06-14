#!/usr/bin/env bash
set -euo pipefail

# Source shared utilities
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/util.sh"

# Defaults
wallpapers_dir="$(xdg-user-dir)/Pictures/Wallpapers"
threshold=80
theme=""
no_filter=false
file_mode=false
dir_mode=false
help_flag=false

# Helpers
get_valid_wallpapers() {
  identify -ping -format '%i\n' "$wallpapers_dir"/** 2>/dev/null || true
}

# Parse flags
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      help_flag=true; shift ;;
    -f|--file)
      file_mode=true
      chosen_file="$2"; shift 2 ;;
    -d|--directory)
      dir_mode=true
      wallpapers_dir="$(realpath "$2")"; shift 2 ;;
    -F|--no-filter)
      no_filter=true; shift ;;
    -t|--threshold)
      threshold="$2"; shift 2 ;;
    -T|--theme)
      theme="$2"; shift 2 ;;
    --)
      shift; break ;;
    -*)
      error "Unknown option: $1"; exit 1 ;;
    *)
      break ;;
  esac
done

# Help message
if [[ "$help_flag" == true ]]; then
  cat <<EOF
Usage:
    $(basename "$0") [ -h ] [ -f <file> | -d <directory> ] [ -F ] [ -t <threshold> ] [ -T <light|dark> ]

Options:
  -h, --help            Show this help and exit
  -f, --file <file>     Use exactly this image file as wallpaper
  -d, --directory <dir> Select a random wallpaper from this directory
                        (default: $wallpapers_dir)
  -F, --no-filter       Skip filtering by resolution threshold
  -t, --threshold <n>   Resolution threshold percentage (default: $threshold)
  -T, --theme <light|dark>
                        Force theme; if omitted, auto-detect from wallpaper
EOF
  exit 0
fi

state_dir="$C_STATE/wallpaper"
mkdir -p "$state_dir"
last_path="$state_dir/last.txt"

# Determine chosen_wallpaper
if [[ "$file_mode" == true ]]; then
  chosen_wallpaper="$(realpath "$chosen_file")"
  if ! identify -ping "$chosen_wallpaper" &>/dev/null; then
    error "Not a valid image: $chosen_wallpaper"; exit 1
  fi

else
  # Ensure directory exists
  if [[ ! -d "$wallpapers_dir" ]]; then
    error "Directory not found: $wallpapers_dir"; exit 1
  fi

  # Gather wallpapers, excluding last
  if [[ -f "$last_path" ]]; then
    last_wallpaper="$(<"$last_path")"
    mapfile -t all_imgs < <(get_valid_wallpapers | grep -vF -- "$last_wallpaper")
  else
    mapfile -t all_imgs < <(get_valid_wallpapers)
  fi

  # Filter by resolution if requested
  if [[ "$no_filter" == false ]]; then
    # Get max-monitor resolution
    read -r mon_w mon_h < <(
      hyprctl monitors -j \
        | jq -r 'max_by(.width*.height) | "\(.width) \(.height)"'
    )
    # Apply threshold
    min_w=$(( mon_w * threshold / 100 ))
    min_h=$(( mon_h * threshold / 100 ))

    imgs=()
    for img in "${all_imgs[@]}"; do
      read -r w h < <(identify -ping -format '%w %h' "$img")
      if (( w >= min_w && h >= min_h )); then
        imgs+=("$img")
      fi
    done
  else
    imgs=("${all_imgs[@]}")
  fi

  if [[ ${#imgs[@]} -eq 0 ]]; then
    error "No valid images in $wallpapers_dir"; exit 1
  fi

  # Pick random
  chosen_wallpaper="${imgs[RANDOM % ${#imgs[@]}]}"
fi

# Prepare thumbnail for colour-scheme generation
thumb_dir="$C_CACHE/thumbnails"
mkdir -p "$thumb_dir"
sha="$(sha1sum <<<"$chosen_wallpaper" | cut -d' ' -f1)"
thumb="$thumb_dir/$sha.jpg"
if [[ ! -f "$thumb" ]]; then
  magick -define jpeg:size=256x256 "$chosen_wallpaper" -thumbnail 128x128 "$thumb"
fi
cp "$thumb" "$state_dir/thumbnail.jpg"

# Determine theme if not forced
if [[ -z "$theme" ]]; then
  lightness=$(magick "$state_dir/thumbnail.jpg" -format '%[fx:int(mean*100)]' info:)
  if (( lightness >= 60 )); then
    theme=light
  else
    theme=dark
  fi
fi

# Generate colour scheme in background
MODE="$theme" "$script_dir/scheme/gen-scheme.fish" &

# Apply the wallpaper
# (Use swaybg/hyprpaper or your compositor’s command here; example for swaybg:)
if command -v hyprpaper &>/dev/null; then
  hyprpaper wallpaper "$chosen_wallpaper"
elif command -v swaybg &>/dev/null; then
  swaybg -i "$chosen_wallpaper" -m fill
else
  # Fallback: set via xwallpaper on X11
  xwallpaper --stretch "$chosen_wallpaper"
fi

# Record chosen wallpaper
echo "$chosen_wallpaper" > "$last_path"
ln -sf "$chosen_wallpaper" "$state_dir/current"
