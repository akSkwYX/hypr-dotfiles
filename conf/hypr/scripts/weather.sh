#!/usr/bin/env bash
#  ┓ ┏┏┓┏┓┏┳┓┓┏┏┓┳┓
#  ┃┃┃┣ ┣┫ ┃ ┣┫┣ ┣┫
#  ┗┻┛┗┛┛┗ ┻ ┛┗┗┛┛┗
#                  


# Displays today's precipication chance ( ), and daily low ( ) and high ( ).
# Usually intended for the statusbar.

url="${WTTRURL:-wttr.in}"
weatherreport="${XDG_CACHE_HOME:-$HOME/.cache}/weatherreport"

# Get a weather report from 'wttr.in' and save it locally.
getforecast() { timeout --signal=1 2s curl -sf "$url/Rouen+France" > "$weatherreport" || exit 1; }

# Forecast should be updated only once a day.
checkforecast() {
	[ -s "$weatherreport" ] && [ "$(stat -c %y "$weatherreport" 2>/dev/null |
		cut -d' ' -f1)" = "$(date '+%Y-%m-%d')" ]
}

getprecipchance() {
	echo "$weatherdata" | sed '16q;d' |    # Extract line 16 from file
		grep -wo "[0-9]*%" |           # Find a sequence of digits followed by '%'
		sort -rn |                     # Sort in descending order
		head -1q                       # Extract first line
}

getdailyhighlow() {
	echo "$weatherdata" | sed '13q;d' |      # Extract line 13 from file
		grep -o "m\\([-+]\\)*[0-9]\\+" | # Find temperatures in the format "m<signed number>"
		sed 's/[+m]//g' |                # Remove '+' and 'm'
		sort -g |                        # Sort in ascending order
		sed -e 1b -e '$!d'               # Extract the first and last lines
}

readfile() { weatherdata="$(cat "$weatherreport")" ;}

showweather() {
	readfile
	printf " %s  %s°  %s°\n" "$(getprecipchance)" $(getdailyhighlow)
}


if [[ "$1" == "--get" ]]; then
	checkforecast || getforecast
        showweather
elif [[ "$1" == "--upd" ]]; then
	getforecast
fi
