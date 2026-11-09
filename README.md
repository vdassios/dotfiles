# dotfiles

Personal Arch Linux configuration. This started as a customization layer on top of DHH's [omarchy](https://learn.omacom.io/2/the-omarchy-manual) and is being pared down toward a barebones Arch setup.

The repository is organized as GNU Stow-style packages — each top-level directory mirrors the layout under `$HOME` (e.g. `hypr/.config/hypr/...`) so the configs can be symlinked straight into place.

## Contents

- [Desktop & window manager](#desktop--window-manager)
- [Shell & terminal](#shell--terminal)
- [Editor (Neovim)](#editor-neovim)
- [System utilities](#system-utilities)
- [Scripts & systemd units](#scripts--systemd-units)

## Desktop & window manager

- **[Hyprland](https://hypr.land/)** — dynamic tiling Wayland compositor. Lua config (0.57+): `hyprland.lua` requires `envs.lua`, `monitors.lua`, `input.lua`, `looknfeel.lua`, `windows.lua`, `bindings.lua`, `autostart.lua`.
- **[Hypridle](https://github.com/hyprwm/hypridle)** — idle daemon that locks the session and turns the display off after a timeout.
- **[Hyprlock](https://github.com/hyprwm/hyprlock)** — screen locker for Hyprland, styled with Catppuccin Macchiato.
- **[Hyprsunset](https://github.com/hyprwm/hyprsunset)** — blue-light / color-temperature manager, run via its packaged user unit (`systemctl --user enable --now hyprsunset.service`).
- **[hyprshutdown](https://github.com/hyprwm/hyprshutdown)** — graceful shutdown: asks apps to close, exits Hyprland, then powers off. Bound to `SUPER+SHIFT+E`.
- **[Hyprshot](https://github.com/Gustash/Hyprshot)** — screenshot utility (window / output / region) bound under `PRINT`.
- **[xdg-desktop-portal-hyprland](https://github.com/hyprwm/xdg-desktop-portal-hyprland)** — XDG portal used for screen sharing and file pickers.
- **[Waybar](https://github.com/Alexays/Waybar)** — top status bar; shows workspaces, clock, keyboard layout, bluetooth, network, audio, CPU, battery.
- **[Walker](https://github.com/abenz1267/walker)** — Wayland application launcher (apps, web search, calc, symbols, clipboard, files). Themed with `macchiatto`.
- **[Elephant](https://github.com/abenz1267/elephant)** — data provider backend for Walker, run as a user systemd service.
- **[Mako](https://github.com/emersion/mako)** — lightweight Wayland notification daemon.
- **[swaybg](https://github.com/swaywm/swaybg)** — Wayland wallpaper setter (loads `~/Wallpapers/cats.png`).
- **[SwayOSD](https://github.com/ErikReider/SwayOSD)** — GTK on-screen display for volume / brightness / caps-lock.
- **[greetd](https://sr.ht/~kennylevinsen/greetd/)** — minimal login manager; customized `banner.txt` greets at the TTY.
- **[uwsm](https://github.com/Vladimir-csp/uwsm)** — Universal Wayland Session Manager, used to launch apps under systemd user scopes.
- **[polkit-gnome](https://gitlab.gnome.org/Archive/policykit-gnome)** — PolicyKit authentication agent for privileged GUI prompts.
- **[fcitx5](https://fcitx-im.org/)** — input method framework (multilingual typing).
- **[qt6-wayland](https://archlinux.org/packages/extra/x86_64/qt6-wayland/)** — native Wayland backend for Qt6 apps (without it they fall back to XWayland despite `QT_QPA_PLATFORM`).
- **[wl-clipboard](https://github.com/bugaevc/wl-clipboard) + [cliphist](https://github.com/sentriz/cliphist)** — clipboard history: `wl-paste --watch cliphist store` runs from `autostart.lua`; `SUPER+V` browses history through Walker's dmenu mode.
- **[playerctl](https://github.com/altdesktop/playerctl)** — MPRIS media-key controller for XF86Audio keys.
- **[brightnessctl](https://github.com/Hummer12007/brightnessctl)** — backlight brightness control used on resume from DPMS off.

## Shell & terminal

- **[Alacritty](https://alacritty.org/)** — GPU-accelerated terminal emulator. Uses MesloLGS Nerd Font and a Catppuccin Macchiato palette.
- **[Zsh](https://www.zsh.org/)** — login shell.
- **[zsh4humans (z4h)](https://github.com/romkatv/zsh4humans)** — Zsh distribution managing fzf, autosuggestions, syntax-highlighting, and SSH teleportation.
- **[Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh)** — pulled in via `z4h install`; the `emoji-clock` plugin is loaded and `diagnostics.zsh` is sourced.
- **[Powerlevel10k](https://github.com/romkatv/powerlevel10k)** — Zsh prompt, configured via `p10k/.p10k.zsh`.
- **[zsh-z](https://github.com/agkozak/zsh-z)** — frecency-based `z` directory jumper (vendored as `zsh/zsh-z.plugin.zsh`).
- **[fnm](https://github.com/Schniz/fnm)** — fast Node.js version manager, with `--use-on-cd`.
- **[direnv](https://direnv.net/)** — per-directory environment variables via `.envrc`, enabled through z4h.
- **[fzf](https://github.com/junegunn/fzf)** — fuzzy finder; color palette overridden to match Catppuccin Macchiato.
- **[tmux](https://github.com/tmux/tmux)** — terminal multiplexer. Prefix remapped to `C-a`, vi mode, mouse on, Catppuccin-inspired status styling.
  - **[tpm](https://github.com/tmux-plugins/tpm)** — tmux plugin manager.
  - **[tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect)** — saves and restores tmux sessions across reboots.

## Editor (Neovim)

[Neovim](https://neovim.io/) configuration based on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim), split into `lua/plugins/*`. Plugins are managed by [lazy.nvim](https://github.com/folke/lazy.nvim) and locked via `lazy-lock.json`.

### Plugin manager & helpers

- **[lazy.nvim](https://github.com/folke/lazy.nvim)** — plugin manager and lockfile-driven loader.
- **[guess-indent.nvim](https://github.com/NMAC427/guess-indent.nvim)** — detects `tabstop` / `shiftwidth` automatically per buffer.
- **[nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons)** — Nerd Font file-type icons used by pickers and the statusline.

### UI & colorscheme

- **[catppuccin/nvim](https://github.com/catppuccin/nvim)** — active colorscheme (`catppuccin-macchiato`).
- **[tokyonight.nvim](https://github.com/folke/tokyonight.nvim)** — alternative colorscheme (installed, currently commented out).
- **[lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)** — statusline with minimal separators.

### Navigation & search

- **[fzf-lua](https://github.com/ibhagwan/fzf-lua)** — fuzzy picker for files, grep, buffers, help, diagnostics, treesitter symbols, and LSP actions (`;f`, `;r`, `;t`, …).
- **[oil.nvim](https://github.com/stevearc/oil.nvim)** — edit the filesystem as a buffer; opened with `sf` as the default explorer.

### LSP, completion & snippets

- **[nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)** — baseline LSP client configs.
- **[mason.nvim](https://github.com/mason-org/mason.nvim)** — installs LSP servers, linters, and formatters.
- **[mason-lspconfig.nvim](https://github.com/mason-org/mason-lspconfig.nvim)** — bridges Mason with nvim-lspconfig.
- **[mason-tool-installer.nvim](https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim)** — declaratively ensures tools are installed.
- **[fidget.nvim](https://github.com/j-hui/fidget.nvim)** — LSP progress notifications in the corner.
- **[lazydev.nvim](https://github.com/folke/lazydev.nvim)** — Lua LSP tuned for the Neovim config runtime (plugin types, `vim.uv`).
- **[blink.cmp](https://github.com/Saghen/blink.cmp)** — completion engine (LSP, path, snippets, lazydev sources).
- **[LuaSnip](https://github.com/L3MON4D3/LuaSnip)** — snippet engine backing blink.cmp.

Configured LSP servers: `lua_ls`, `ts_ls`, `cssls`, `tailwindcss`, `html`, `yamlls`.

### Formatting & linting

- **[conform.nvim](https://github.com/stevearc/conform.nvim)** — format-on-save. Uses `stylua` (Lua), `isort`+`black` (Python), `prettierd`/`prettier` (JS/TS/JSON/HTML), `dockerfmt`, `rustywind`, `tombi`, `markdownlint`, `beautysh`.
- **[nvim-lint](https://github.com/mfussenegger/nvim-lint)** — async linting. Uses `eslint_d` (JS/TS/CSS), `markdownlint`, `jsonlint`, `hadolint`, `vale`.

### Syntax & editing

- **[nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)** — incremental parser for syntax highlighting and indentation (bash, c, lua, rust, go, astro, html, css, markdown, diff, …).
- **[gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim)** — gutter signs plus hunk stage/reset/preview/blame keymaps.
- **[nvim-autopairs](https://github.com/windwp/nvim-autopairs)** — automatic bracket / quote pairing.

## System utilities

Bound in Hyprland or called from scripts:

- **[yazi](https://github.com/sxyzxun/yazi)** — blazing-fast terminal file manager, bound to `SUPER+F` and wrapped by a `y` shell function that CDs to its last directory.
- **[btop](https://github.com/aristocratos/btop)** — resource monitor, bound to `SUPER+T`.
- **[lazydocker](https://github.com/jesseduffield/lazydocker)** — TUI for Docker, bound to `SUPER+D`.
- **[pamixer](https://github.com/cdemoulins/pamixer)** — PulseAudio volume CLI used by the Waybar audio module.
- **[gum](https://github.com/charmbracelet/gum)** — interactive TUI prompts used by `tz-select.sh` (styled via `GUM_*` vars in `envs.lua`).
- **[jq](https://jqlang.org/)** — JSON query tool used in scripts (e.g. `launch-or-focus.sh`) to parse `hyprctl` output.
- **[Obsidian](https://obsidian.md/)** — markdown notes app (`SUPER+O`).
- **[Signal](https://signal.org/)** — messaging app (`SUPER+G`).

## Scripts & systemd units

- `scripts/` — helper shell scripts (launchers, battery monitor, screen lock, timezone picker, terminal CWD reporter). The `scripts/README.md` describes copying them into `~/.local/bin/`.
- `systemd/.config/systemd/user/` — user units:
  - `battery-monitor.service` / `.timer` — periodic low-battery notifier.
  - `elephant.service` — keeps the Elephant data provider running for Walker.
- `themes/` — extra app themes (currently a qBittorrent Iceberg theme).
