#!/usr/bin/env bash

# Terminate already running bar instances
# If all your bars have ipc enabled, you can use 
polybar-msg cmd quit
# Otherwise you can use the nuclear option:
# killall -q polybar

# Launch bar top
echo "---" | tee -a /tmp/polybartop.log
polybar top --config=~/.config/polybar/config.ini 2>&1 | tee -a /tmp/polybartop.log & disown

echo "Bars launched..."
