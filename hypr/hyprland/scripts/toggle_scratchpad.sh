#!/usr/bin/env bash

app_cmd="$1"
scratchpad="$2"
shift 2

if [ -z "$app_cmd" ] || [ -z "$scratchpad" ] || [ "$#" -eq 0 ]; then
    echo "Usage: $0 <app_cmd> <scratchpad> <class> [class...]"
    exit 1
fi

found=false
clients=$(hyprctl clients)
for class in "$@"; do
    if echo "$clients" | grep -q -E "^[[:space:]]*(initialClass|class): $class$"; then
        found=true
        break
    fi
done

if ! $found; then
    hyprctl dispatch exec "[workspace special:$scratchpad silent] $app_cmd"
fi

hyprctl dispatch togglespecialworkspace "$scratchpad"