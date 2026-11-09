# Copy over the keyboard layout that's been set in Arch during install to Hyprland
conf="/etc/vconsole.conf"
hyprconf="$HOME/.config/hypr/input.lua"

if grep -q '^XKBLAYOUT=' "$conf"; then
  layout=$(grep '^XKBLAYOUT=' "$conf" | cut -d= -f2 | tr -d '"')
  sed -i -E "s/^([[:space:]]*kb_layout[[:space:]]*=[[:space:]]*)\"[^\"]*\"/\1\"$layout\"/" "$hyprconf"
fi

if grep -q '^XKBVARIANT=' "$conf"; then
  variant=$(grep '^XKBVARIANT=' "$conf" | cut -d= -f2 | tr -d '"')
  if grep -qE '^[[:space:]]*kb_variant[[:space:]]*=' "$hyprconf"; then
    sed -i -E "s/^([[:space:]]*kb_variant[[:space:]]*=[[:space:]]*)\"[^\"]*\"/\1\"$variant\"/" "$hyprconf"
  else
    sed -i -E "/^[[:space:]]*kb_layout[[:space:]]*=/a\\        kb_variant = \"$variant\"," "$hyprconf"
  fi
fi
