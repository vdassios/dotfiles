#!/bin/bash

# Boot chain 4/4 — install the greetd config + tuigreet banner into /etc/greetd.
# Sources live in the `greetd` Stow package; they are copied (not symlinked)
# because greetd runs the greeter as the `greeter` user, which cannot read $HOME.
set -euo pipefail

src="$(cd "$(dirname "$0")/../../linux/greetd/.config/greetd" && pwd)"

sudo pacman -S --needed greetd greetd-tuigreet

sudo install -Dm644 "$src/config.toml" /etc/greetd/config.toml

# banner.txt stores colours as literal `\033[...m`; expand them to real escape
# bytes. tuigreet centres each line independently, which skews ASCII art, so
# the config uses --greet-align left and the indent here centres the block.
printf '%b' "$(cat "$src/banner.txt")" | sed 's/^/                  /' |
  sudo install -Dm644 /dev/stdin /etc/greetd/banner

sudo systemctl enable greetd.service
echo "greetd configured — takes effect on next boot (restarting greetd now would end this session)."
