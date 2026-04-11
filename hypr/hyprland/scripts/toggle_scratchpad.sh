#!/usr/bin/env bash

app_cmd="$1"
scratchpad="$2"
shift 2

if [ -z "$app_cmd" ] || [ -z "$scratchpad" ] || [ "$#" -eq 0 ]; then
    echo "Usage: $0 <app_cmd> <scratchpad> <class> [class...]"
    exit 1
fi

client_info=$(hyprctl clients -j | python3 -c '
import json, sys

classes = set(sys.argv[1:])
clients = json.load(sys.stdin)
for client in clients:
    client_class = client.get("class", "")
    initial_class = client.get("initialClass", "")
    if client_class in classes or initial_class in classes:
        workspace = (client.get("workspace") or {}).get("name", "")
        address = client.get("address", "")
        print(f"{address}|{workspace}")
        break
' "$@")

if [ -z "$client_info" ]; then
    hyprctl dispatch exec "[workspace special:'$scratchpad' silent]" "$app_cmd"
    exit 0
fi

address="${client_info%%|*}"
workspace="${client_info#*|}"
target_workspace="special:$scratchpad"

special_visible=$(hyprctl monitors -j | python3 -c '
import json, sys

target_workspace = sys.argv[1]
monitors = json.load(sys.stdin)
for monitor in monitors:
    special = monitor.get("specialWorkspace") or {}
    if special.get("name") == target_workspace:
        print("yes")
        break
' "$target_workspace")

if [ "$workspace" != "$target_workspace" ]; then
    hyprctl dispatch movetoworkspacesilent "special:$scratchpad,address:$address"
    hyprctl dispatch togglespecialworkspace "$scratchpad"
    hyprctl dispatch focuswindow "address:$address"
    exit 0
fi

hyprctl dispatch togglespecialworkspace "$scratchpad"

if [ "$special_visible" != "yes" ]; then
    hyprctl dispatch focuswindow "address:$address"
fi