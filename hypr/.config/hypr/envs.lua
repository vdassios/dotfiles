-- Environment variables, set before the display server initializes.
-- See https://wiki.hypr.land/configuring/core/environment-variables/
-- Reference existing variables via os.getenv().

local home = os.getenv("HOME")

-- So that we can launch scripts from hyprland bindings
hl.env("PATH", home .. "/.local/bin:/usr/local/bin:/usr/bin")

-- Cursor size
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Force all apps to use Wayland
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_STYLE_OVERRIDE", "kvantum")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")
hl.env("OZONE_PLATFORM", "wayland")
hl.env("XDG_SESSION_TYPE", "wayland")

-- Allow better support for screen sharing (Google Meet, Discord, etc)
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- Route GTK3 apps' and Firefox's file pickers through the portal, which hands
-- them to yazi (see portals/ Stow package). Chromium uses the portal on its own.
hl.env("GTK_USE_PORTAL", "1")

-- Set hyprshot save directory
hl.env("HYPRSHOT_DIR", home .. "/Pictures/Screenshots")

-- Style Gum confirm to match terminal theme
hl.env("GUM_CONFIRM_PROMPT_FOREGROUND", "6")     -- Cyan
hl.env("GUM_CONFIRM_SELECTED_FOREGROUND", "0")   -- Black
hl.env("GUM_CONFIRM_SELECTED_BACKGROUND", "2")   -- Green
hl.env("GUM_CONFIRM_UNSELECTED_FOREGROUND", "0") -- Black
hl.env("GUM_CONFIRM_UNSELECTED_BACKGROUND", "8") -- Dark grey

hl.config({
    xwayland = {
        force_zero_scaling = true,
    },
})
