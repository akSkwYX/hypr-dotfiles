#!/usr/bin/env bash

# Set warning suppression rules
dbus='quickshell.dbus.properties.warning = false;quickshell.dbus.dbusmenu.warning = false'
notifs='quickshell.service.notifications.warning = false'
sni='quickshell.service.sni.host.warning = false'
process='QProcess: Destroyed while process'
cache="Cannot open: file://$XDG_CACHE_HOME/caelestia/imagecache/"

# Get script directory
script_dir="$(dirname "$0")"

# Run the quickshell command and filter warnings
qs -p "$script_dir" --log-rules "$dbus;$notifs;$sni" | grep -vF -e "$process" -e "$cache"
