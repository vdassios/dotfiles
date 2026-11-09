-- See https://wiki.hypr.land/configuring/core/rules/
-- Effects are processed top to bottom; the last match wins.
-- Rules are left unnamed on purpose: named rules are evaluated before
-- anonymous ones, which would change the ordering below.

-- Ignore maximize requests from all apps
hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize" })

-- Just dash of opacity by default
hl.window_rule({ match = { class = ".*" }, opacity = "0.97 0.9" })

-- Fix some dragging issues with XWayland
hl.window_rule({
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

-- App-specific tweaks

-- System
-- Floating windows
hl.window_rule({
    match  = { tag = "floating-window" },
    float  = true,
    center = true,
    size   = { 875, 600 },
})

-- No transparency on media windows
hl.window_rule({
    match   = { class = "^(zoom|vlc|mpv|org.kde.kdenlive|com.obsproject.Studio|com.github.PintaProject.Pinta|imv|org.gnome.NautilusPreviewer)$" },
    opacity = "1 1",
})

-- Popped window rounding
hl.window_rule({ match = { tag = "pop" }, rounding = 8 })

-- Prevent idle while open
hl.window_rule({ match = { tag = "noidle" }, idle_inhibit = "always" })

-- Browser
-- Browser types
hl.window_rule({
    match = { class = "((google-)?[cC]hrom(e|ium)|[bB]rave-browser|[mM]icrosoft-edge|Vivaldi-stable|helium)" },
    tag   = "+chromium-based-browser",
})
hl.window_rule({
    match = { class = "([fF]irefox|zen|librewolf)" },
    tag   = "+firefox-based-browser",
})

-- Force chromium-based browsers into a tile to deal with --app bug
hl.window_rule({ match = { tag = "chromium-based-browser" }, tile = true })

-- Only a subtle opacity change, but not for video sites
hl.window_rule({ match = { tag = "chromium-based-browser" }, opacity = "1 0.97" })
hl.window_rule({ match = { tag = "firefox-based-browser" },  opacity = "1 0.97" })

-- Some video sites should never have opacity applied to them
hl.window_rule({
    match   = { initial_title = "((?i)(?:[a-z0-9-]+\\.)*youtube\\.com_/|app\\.zoom\\.us_/wc/home)" },
    opacity = "1.0 1.0",
})

-- Terminals
-- Define terminal tag to style them uniformly
hl.window_rule({
    match = { class = "(Alacritty|kitty|com.mitchellh.ghostty)" },
    tag   = "+terminal",
})

-- Walker
-- Application-specific animation
hl.layer_rule({ match = { namespace = "walker" }, no_anim = true })
-- hl.layer_rule({ match = { namespace = "walker" }, blur = true })

-- Webcam
-- Webcam overlay for screen recording
hl.window_rule({
    match            = { title = "WebcamOverlay" },
    float            = true,
    pin              = true,
    no_initial_focus = true,
    no_dim           = true,
    move             = { "monitor_w-window_w-40", "monitor_h-window_h-40" },
})
