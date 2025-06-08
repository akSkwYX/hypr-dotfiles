#!/usr/bin/env bash
#  ┏┓┏┓┳┓┏┓┳┓┏┓┏┳┓┏┓┳┓ ┏┓
#  ┗┓┃┃┃┃┃┓┃┃┣  ┃ ┣┫┃┃ ┗┓
#  ┗┛┗┛┛┗┗┛┻┛┗┛ ┻ ┛┗┻┗┛┗┛


icon_playing=""
icon_paused=""

declare -A player_icons=(
   [spotify]=""
   [firefox]="󰈹"
   [chromium]=""
   [vlc]="󰕼"
   [mpv]=""
   [unknown]=""
)

info_line=()

mapfile -t players < <(playerctl -l 2>/dev/null)

for player in "${players[@]}"; do
   status=$(playerctl -p "$player" status 2>/dev/null)

   case "$status" in
      "Playing")
         status_icon="$icon_playing"
         ;;
      "Paused")
         status_icon="$icon_paused"
         ;;
      *)
         continue
         ;;
   esac

   title=$(playerctl -p "$player" metadata title 2>/dev/null)
   artist=$(playerctl -p "$player" metadata artist 2>/dev/null)

   [[ -z $title ]] && title="Unknown"
   [[ -z $artist ]] && artist="Unknown"

   player_key=$(echo "$player" | sed -E 's/\..*$//' | tr '[:upper:]' '[:lower:]')
   icon="${player_icons[$player_key]:-${player_icons[unknown]}}"

   metadata=$(playerctl -p "$player" metadata --format "{{title}} - {{artist}}" 2>/dev/null)
   song_info="$icon : $status_icon $metadata"
   info_lines+=("$song_info")
done

printf "%s\n" "${info_lines[@]}"
