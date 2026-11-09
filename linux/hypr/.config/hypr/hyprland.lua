-- Learn how to configure Hyprland: https://wiki.hypr.land/configuring/
--
-- Since Hyprland 0.57 the hyprlang (.conf) format is no longer supported;
-- the config is Lua. This file stays thin and pulls in the split modules
-- below (each `require` runs in its own scope, so an error in one file does
-- not stop the others from loading).
--
-- Modules resolve relative to this file, i.e. ~/.config/hypr/<name>.lua.
-- API stubs for LSP autocompletion: /usr/share/hypr/stubs/
--
-- NOTE: hyprlock.conf, hypridle.conf, hyprsunset.conf, xdph.conf and
-- catppuccin_macchiato.conf belong to the other hypr* tools, which still use
-- hyprlang. They are not loaded by Hyprland itself.

require("envs")
require("monitors")
require("input")
require("looknfeel")
require("windows")
require("bindings")
require("autostart")
