#!/usr/bin/env bash
# Highlights the focused AeroSpace workspace. $1 is this item's workspace id.
# FOCUSED_WORKSPACE comes with the aerospace_workspace_change event; on the
# initial `sketchybar --update` it is unset, so ask AeroSpace directly.

focused="${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused)}"

if [ "$1" = "$focused" ]; then
    sketchybar --set "$NAME" background.drawing=on
else
    sketchybar --set "$NAME" background.drawing=off
fi
