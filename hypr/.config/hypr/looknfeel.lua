-- Refer to https://wiki.hypr.land/configuring/core/config-options/

-- Variables
local activeBorderColor = "rgba(cad3f5aa)"
local inactiveBorderColor = "rgba(00000000)"

hl.config({
    general = {
        gaps_in = 1,
        gaps_out = 8,
        -- Change value to 1 to enable active border only
        border_size = 0,

        col = {
            active_border = activeBorderColor,
            inactive_border = inactiveBorderColor,
        },

        -- Set to true enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = false,

        -- Please see https://wiki.hypr.land/configuring/extra/tearing/ before you turn this on
        allow_tearing = false,

        layout = "dwindle",
    },

    decoration = {
        rounding = 5,

        shadow = {
            enabled = true,
            range = 2,
            render_power = 3,
            color = "rgba(1a1a1aee)",
        },

        blur = {
            enabled = true,
            size = 2,
            passes = 2,
            special = true,
            brightness = 0.60,
            contrast = 0.75,
        },
    },

    group = {
        col = {
            border_active = activeBorderColor,
            border_inactive = inactiveBorderColor,
            border_locked_active = activeBorderColor,
            border_locked_inactive = inactiveBorderColor,
        },

        groupbar = {
            font_size = 12,
            font_family = "monospace",
            font_weight_active = "ultraheavy",
            font_weight_inactive = "normal",

            indicator_height = 0,
            indicator_gap = 5,
            height = 22,
            gaps_in = 5,
            gaps_out = 0,

            text_color = "rgb(ffffff)",
            text_color_inactive = "rgba(ffffff90)",
            col = {
                active = "rgba(00000040)",
                inactive = "rgba(00000020)",
            },

            gradients = true,
            gradient_rounding = 0,
            gradient_round_only_edges = false,
        },
    },

    animations = {
        enabled = true, -- yes, please :)
    },

    -- See https://wiki.hypr.land/configuring/layouts/dwindle-layout/
    -- (the old `pseudotile` switch was removed upstream; pseudotiling is
    -- always available via hl.dsp.window.pseudo())
    dwindle = {
        preserve_split = true, -- You probably want this
        force_split = 2,       -- Always split on the right
    },

    -- See https://wiki.hypr.land/configuring/layouts/master-layout/
    master = {
        new_status = "master",
    },

    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        focus_on_activate = true,
        anr_missed_pings = 3,
        on_focus_under_fullscreen = 1,
    },

    -- New upstream default: let newly mapped top layers (walker, notifications,
    -- OSD) render above an existing fullscreen window.
    layers = {
        allow_new_top_layers_over_existing_fullscreen = true,
    },

    cursor = {
        hide_on_key_press = true,
    },
})

-- Animations, see https://wiki.hypr.land/configuring/core/animations/
hl.curve("easeOutQuint",   { type = "bezier", points = { { 0.23, 1 },    { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear",         { type = "bezier", points = { { 0, 0 },       { 1, 1 } } })
hl.curve("almostLinear",   { type = "bezier", points = { { 0.5, 0.5 },   { 0.75, 1 } } })
hl.curve("quick",          { type = "bezier", points = { { 0.15, 0 },    { 0.1, 1 } } })

-- Spring curve (new upstream default for window motion)
hl.curve("easy", { type = "spring", mass = 1, stiffness = 238.1191, damping = 24.21279333 })

hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  spring = "easy",         style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "zoomFactor",    enabled = true, speed = 7,    bezier = "quick" })
-- Workspace switching is instant (no animation)
hl.animation({ leaf = "workspaces",    enabled = false })
