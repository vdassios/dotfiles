-- See https://wiki.hypr.land/configuring/core/binds/
-- and https://wiki.hypr.land/configuring/core/dispatchers/
--
-- I have switched ALT with SUPER! see input.lua
-- Every bind carries a description so `hyprctl binds` / launchers can list them.

local mainMod = "SUPER"
local browser = "launch-browser"

local function bind(keys, dispatcher, description, opts)
    opts = opts or {}
    opts.description = description
    return hl.bind(keys, dispatcher, opts)
end

-- Workspaces
-- Switch workspaces with SUPER + [0-9]
-- Move active window to a workspace with SUPER + SHIFT + [0-9]
-- Keycodes (code:10 .. code:19) keep these layout-independent (us/gr).
for i = 1, 10 do
    local key = "code:" .. (9 + i)
    bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }), "Switch to workspace " .. i)
    bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i, follow = true }), "Move window to workspace " .. i)
end

-- Window navigation
-- Move focus with mainMod + hjkl
bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }),  "Focus left")
bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }), "Focus right")
bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }),    "Focus up")
bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }),  "Focus down")

-- Move/resize windows with mainMod + LMB/RMB and dragging
bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   "Move window",   { mouse = true })
bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), "Resize window", { mouse = true })

-- Switch panes
bind(mainMod .. " + CTRL + H", hl.dsp.window.move({ direction = "left" }),  "Move window left")
bind(mainMod .. " + CTRL + L", hl.dsp.window.move({ direction = "right" }), "Move window right")
bind(mainMod .. " + CTRL + K", hl.dsp.window.move({ direction = "up" }),    "Move window up")
bind(mainMod .. " + CTRL + J", hl.dsp.window.move({ direction = "down" }),  "Move window down")

-- Screenshots
bind(mainMod .. " + Print",         hl.dsp.exec_cmd("hyprshot -m window"), "Screenshot window")
bind("Print",                       hl.dsp.exec_cmd("hyprshot -m output"), "Screenshot monitor")
bind(mainMod .. " + SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m region"), "Screenshot region")

-- Applications
bind(mainMod .. " + Return", hl.dsp.exec_cmd('uwsm-app -- xdg-terminal-exec --dir="$(cmd-terminal-cwd)"'), "Terminal")
bind(mainMod .. " + F", hl.dsp.exec_cmd("launch-tui yazi"), "File manager")
bind(mainMod .. " + B", hl.dsp.exec_cmd(browser), "Browser")
bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd(browser .. " --private"), "Browser (private)")
bind(mainMod .. " + T", hl.dsp.exec_cmd("launch-tui btop"), "Activity")
bind(mainMod .. " + D", hl.dsp.exec_cmd("launch-tui lazydocker"), "Docker")
bind(mainMod .. " + G", hl.dsp.exec_cmd('launch-or-focus signal "uwsm app -- signal-desktop"'), "Signal")
bind(mainMod .. " + O", hl.dsp.exec_cmd('launch-or-focus obsidian "uwsm app -- obsidian -disable-gpu --enable-wayland-ime"'), "Obsidian")
bind(mainMod .. " + Space", hl.dsp.exec_cmd("launch-walker"), "Launch Apps")
-- (No more `##` escaping for `#` in URLs: this is a plain Lua string now.)
bind(mainMod .. " + A", hl.dsp.exec_cmd('launch-webapp "https://chatgpt.com"'), "ChatGPT")
bind(mainMod .. " + E", hl.dsp.exec_cmd('launch-webapp "https://mail.google.com/mail/u/0/#inbox"'), "Email")
bind(mainMod .. " + S", hl.dsp.exec_cmd("lock-screen"), "Lock Screen")
bind(mainMod .. " + V", hl.dsp.exec_cmd("cliphist list | launch-walker --dmenu | cliphist decode | wl-copy"), "Clipboard history")

-- change close window to be i3 consistent
bind(mainMod .. " + SHIFT + Q", hl.dsp.window.close(), "Close window")

-- shutdown hotkey: hyprshutdown asks apps to close cleanly (unsaved-work
-- prompts still appear), exits Hyprland, then powers off.
bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd('hyprshutdown -t "Shutting down..." -p "systemctl poweroff"'), "Shutdown")

-- MEDIA
-- Only display the OSD on the currently focused monitor. Resolved at
-- keypress time from Lua (no hyprctl | jq round-trip needed).
local function osd(args)
    return function()
        local monitor = hl.get_active_monitor()
        local target = monitor and (" --monitor " .. monitor.name) or ""
        hl.dispatch(hl.dsp.exec_cmd("swayosd-client" .. target .. " " .. args))
    end
end

local lockedRepeat = { locked = true, repeating = true }

-- Laptop multimedia keys for volume and LCD brightness (with OSD)
bind("XF86AudioRaiseVolume",  osd("--output-volume raise"),       "Volume up",        lockedRepeat)
bind("XF86AudioLowerVolume",  osd("--output-volume lower"),       "Volume down",      lockedRepeat)
bind("XF86AudioMute",         osd("--output-volume mute-toggle"), "Mute",             lockedRepeat)
bind("XF86AudioMicMute",      osd("--input-volume mute-toggle"),  "Mute microphone",  lockedRepeat)
bind("XF86MonBrightnessUp",   osd("--brightness raise"),          "Brightness up",    lockedRepeat)
bind("XF86MonBrightnessDown", osd("--brightness lower"),          "Brightness down",  lockedRepeat)

-- remember that I have switched alt with SUPER, so this is actually windows key
-- Precise 1% multimedia adjustments with Alt modifier
bind("ALT + XF86AudioRaiseVolume",  osd("--output-volume +1"), "Volume up precise",       lockedRepeat)
bind("ALT + XF86AudioLowerVolume",  osd("--output-volume -1"), "Volume down precise",     lockedRepeat)
bind("ALT + XF86MonBrightnessUp",   osd("--brightness +1"),    "Brightness up precise",   lockedRepeat)
bind("ALT + XF86MonBrightnessDown", osd("--brightness -1"),    "Brightness down precise", lockedRepeat)

-- Requires playerctl
bind("XF86AudioNext",  osd("--playerctl next"),       "Next track",     { locked = true })
bind("XF86AudioPause", osd("--playerctl play-pause"), "Pause",          { locked = true })
bind("XF86AudioPlay",  osd("--playerctl play-pause"), "Play",           { locked = true })
bind("XF86AudioPrev",  osd("--playerctl previous"),   "Previous track", { locked = true })
