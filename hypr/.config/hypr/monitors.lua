-- See https://wiki.hypr.land/configuring/core/monitors/
-- List current monitors and resolutions possible: hyprctl monitors
-- Format: hl.monitor({ output, mode, position, scale, mirror? })
-- `output = ""` matches any monitor not explicitly configured.
-- You must relaunch Hyprland after changing any envs.
--
-- Host-specific: keep local tweaks out of commits where possible.

-- Optimized for retina-class 2x displays, like 13" 2.8K, 27" 5K, 32" 6K.
-- hl.env("GDK_SCALE", "2")
-- hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

-- Good compromise for 27" or 32" 4K monitors (but fractional!)
hl.env("GDK_SCALE", "1.75")
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })

-- Mirroring needs the name of the output to mirror, e.g.:
-- hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6, mirror = "eDP-1" })

-- Straight 1x setup for low-resolution displays like 1080p or 1440p
-- hl.env("GDK_SCALE", "1")
-- hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

-- Example for Framework 13 w/ 6K XDR Apple display
-- hl.monitor({ output = "DP-5", mode = "6016x3384@60", position = "auto", scale = 2 })
-- hl.monitor({ output = "eDP-1", mode = "2880x1920@120", position = "auto", scale = 2 })
