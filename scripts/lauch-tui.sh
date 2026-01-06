#!/bin/bash

# Launch the TUI command passed in as an argument in the default terminal with an COMMAND app id for styling.

exec setsid uwsm-app -- xdg-terminal-exec --app-id=$(basename $1) -e "$1" "${@:2}"
