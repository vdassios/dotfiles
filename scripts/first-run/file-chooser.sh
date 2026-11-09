#!/bin/bash

# Use yazi for "Open file" / "Save as" dialogs (browsers, GTK apps, Electron).
# Config lives in the `portals` Stow package:
#   ~/.config/xdg-desktop-portal/hyprland-portals.conf   (routes FileChooser)
#   ~/.config/xdg-desktop-portal-termfilechooser/config  (yazi + terminal)
yay -S --needed xdg-desktop-portal-termfilechooser

systemctl --user restart xdg-desktop-portal.service
