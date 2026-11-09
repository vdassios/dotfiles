-- Autostart processes, see https://wiki.hypr.land/configuring/core/autostart/
-- Runs once per Hyprland session (the Lua equivalent of exec-once).

hl.on("hyprland.start", function()
    -- Export the session env (PATH, Wayland vars, ...) to systemd and D-Bus
    -- first, so apps launched below and via uwsm-app/D-Bus activation see it.
    -- (Slow app launch fix. Hyprland already exports the core vars itself;
    -- this keeps exporting *everything*, as before.)
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")

    -- Controls idle/sleep settings.
    hl.exec_cmd("uwsm-app -- hypridle")
    -- Wayland notification daemon
    hl.exec_cmd("uwsm-app -- mako")
    -- Waybar settings
    hl.exec_cmd("uwsm-app -- waybar")
    -- Input method framework (Greek/compose input in GTK/Qt apps)
    hl.exec_cmd("uwsm-app -- fcitx5")
    -- Wayland background
    hl.exec_cmd("uwsm-app -- swaybg -i ~/Wallpapers/cats.png -m fill")
    -- Show volume status with swayOSD
    hl.exec_cmd("uwsm-app -- swayosd-server")
    -- Clipboard history (text and images), browsed with SUPER + V
    hl.exec_cmd("uwsm-app -- wl-paste --type text --watch cliphist store")
    hl.exec_cmd("uwsm-app -- wl-paste --type image --watch cliphist store")
    -- Set polkit authentication agent
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
end)
