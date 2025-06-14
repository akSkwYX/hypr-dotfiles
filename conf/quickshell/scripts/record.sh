#!/usr/bin/env bash
set -euo pipefail

# Determine script directory
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source shared utilities (logging, etc.)
source "$script_dir/util.sh"

# Helpers
get_audio_source() {
  pactl list short sources \
    | grep '\.monitor.*RUNNING' \
    | cut -f2 \
    | head -n1
}

get_region() {
  slurp || exit 0
}

get_active_monitor() {
  hyprctl monitors -j \
    | jq -r '.[] | select(.focused==true) | .name'
}

# Default flags
flag_help=false
flag_sound=false
flag_nohw=false
flag_region_set=false
flag_region_value=""

# Parse flags (short + long)
while (( $# )); do
  case "$1" in
    -h|--help)         flag_help=true;      shift ;;
    -s|--sound)        flag_sound=true;     shift ;;
    -N|--no-hwaccel)   flag_nohw=true;      shift ;;
    -r|--region)
      flag_region_set=true
      if [[ "$1" == *=* ]]; then
        # --region=value
        flag_region_value="${1#*=}"
        shift
      else
        # flag without value—use slurp at runtime
        flag_region_value="__SLURP__"
        shift
      fi
      ;;
    --region=*)        flag_region_set=true; flag_region_value="${1#*=}"; shift ;;
    -*)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
    *) break ;;
  esac
done

if [[ "$flag_help" == true ]]; then
  cat <<EOF
Usage:
    caelestia record ( -h | --help )
    caelestia record [ -s | --sound ] [ -r[=<region>] | --region[=<region>] ] [ -N | --no-hwaccel ]

Options:
    -h, --help            Show this message and exit
    -s, --sound           Capture audio
    -r, --region[=value]  Region to record; if no =value, slurp; if flag absent, record active monitor
    -N, --no-hwaccel      Disable GPU encoding
EOF
  exit 0
fi

# Directories & paths
storage_dir="$(xdg-user-dir VIDEOS)/Recordings"
state_dir="$C_STATE/record"
mkdir -p "$storage_dir" "$state_dir"

file_ext="mp4"
recording_path="$state_dir/recording.$file_ext"
notif_id_path="$state_dir/notifid.txt"

# If a recording is in progress, stop it and handle the file
if pgrep wl-screenrec &>/dev/null; then
  pkill wl-screenrec

  timestamp=$(date '+%Y%m%d_%H-%M-%S')
  new_path="$storage_dir/recording_$timestamp.$file_ext"
  mv "$recording_path" "$new_path"

  # Close previous notification
  if [[ -f "$notif_id_path" ]]; then
    notif_id=$(<"$notif_id_path")
    gdbus call --session \
      --dest org.freedesktop.Notifications \
      --object-path /org/freedesktop/Notifications \
      --method org.freedesktop.Notifications.CloseNotification "$notif_id"
  fi

  # Send completion notification with actions
  action=$(notify-send 'Recording stopped' "Saved to $new_path" \
    -i video-x-generic -a caelestia-record \
    --action=watch=Watch \
    --action=open=Open \
    --action=save=Save\ As \
    --action=delete=Delete -p)

  case "$action" in
    watch) app2unit -O "$new_path" ;;
    open)
      dbus-send --session \
        --dest org.freedesktop.FileManager1 \
        --type=method_call \
        /org/freedesktop/FileManager1 \
        org.freedesktop.FileManager1.ShowItems \
        array:string:"file://$new_path" string:'' \
      || app2unit -O "$(dirname "$new_path")"
      ;;
    save)
      save_file=$(app2unit -- zenity --file-selection --save --title='Save As')
      if [[ -n "$save_file" ]]; then
        mv "$new_path" "$save_file"
      else
        warn "No file selected"
      fi
      ;;
    delete) rm -f "$new_path" ;;
  esac

  exit 0
fi

# Determine capture region
if [[ "$flag_region_set" == true ]]; then
  if [[ "$flag_region_value" == "__SLURP__" ]]; then
    region="$(get_region)"
  else
    region="$flag_region_value"
  fi
else
  region="$(get_active_monitor)"
fi

# Build audio args
audio_args=()
if [[ "$flag_sound" == true ]]; then
  audio_device=$(get_audio_source)
  audio_args=(--audio --audio-device "$audio_device")
fi

# Hardware acceleration arg
hw_args=()
if [[ "$flag_nohw" == true ]]; then
  hw_args=(--no-hw)
fi

# Start recording
wl-screenrec "$region" "${audio_args[@]}" "${hw_args[@]}" \
  --codec hevc -f "$recording_path" & disown

# Notify start and record its ID
notify-send 'Recording started' 'Recording…' \
  -i video-x-generic -a caelestia-record -p > "$notif_id_path"
