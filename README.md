# dotfiles

Personal configuration for two machines: an Arch Linux desktop and a macOS MacBook Air. The Arch side started as a customization layer on top of DHH's [omarchy](https://learn.omacom.io/2/the-omarchy-manual) and is being pared down toward a barebones Arch setup.

## Layout

The repository is organized as GNU Stow packages, grouped by the OS they apply to. Each package mirrors the layout under `$HOME` (e.g. `linux/hypr/.config/hypr/...`) so the configs can be symlinked straight into place.

- `common/` — packages used on both machines (alacritty, nvim, p10k, themes, tmux, yazi, zsh).
- `linux/` — Arch-only packages (Hyprland, Waybar, Walker, mako, greetd, portals, systemd units, desktop entries).
- `macos/` — macOS-only packages (AeroSpace, SDKMAN, SketchyBar).
- `scripts/` — not a Stow package; see [Scripts & systemd units](#scripts--systemd-units).

`./stow-dotfiles.sh` stows every package in `common/` plus every package in the folder for the current OS. It is safe to re-run after pulling.

**Per-OS values in shared configs.** When a common config needs a value that differs per OS, it includes a file from `~/.config/dotfiles-os/`. Each OS folder has a `dotfiles-os` package that provides that directory, so whichever package is stowed decides the value:

- `common/alacritty` imports `~/.config/dotfiles-os/alacritty.toml` (font family and size).
- `common/zsh/.zshrc` sources `~/.config/dotfiles-os/env.zsh` first (Homebrew's PATH on macOS) and `zshrc.zsh` at the end (`JAVA_HOME`; SDKMAN on macOS).

The fragments live in a separate directory rather than next to the shared config because Stow can't merge one target directory from packages in two different stow directories (`common/` and `linux/`).

**Adding a new tool:** move its config into a package (`mv ~/.config/foo common/foo/.config/`, or under `linux/` or `macos/` if it's OS-only), run `./stow-dotfiles.sh`, then commit.

**Fresh Mac:** install SDKMAN first, delete the `~/.sdkman/etc/config` it generates, then run `./stow-dotfiles.sh`. The installer is expected to refuse an existing `~/.sdkman`, and stow refuses to replace a file it doesn't own.

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
- **[xdg-desktop-portal-hyprland](https://github.com/hyprwm/xdg-desktop-portal-hyprland)** — XDG portal used for screen sharing.
- **[xdg-desktop-portal-termfilechooser](https://github.com/hunkyburrito/xdg-desktop-portal-termfilechooser)** (AUR) — routes "Open file" / "Save as" dialogs (Chromium, Firefox, GTK apps) to yazi in a floating Alacritty window. Configured in the `portals` package; `GTK_USE_PORTAL=1` in `envs.lua` opts Firefox/GTK3 in.
- **[Waybar](https://github.com/Alexays/Waybar)** — top status bar; shows workspaces, clock, keyboard layout, bluetooth, network, audio, CPU, battery.
- **[Walker](https://github.com/abenz1267/walker)** — Wayland application launcher (apps, web search, calc, symbols, clipboard, files). Themed with `macchiatto`.
- **[Elephant](https://github.com/abenz1267/elephant)** — data provider backend for Walker, run as a user systemd service.
- **[Mako](https://github.com/emersion/mako)** — lightweight Wayland notification daemon.
- **[swaybg](https://github.com/swaywm/swaybg)** — Wayland wallpaper setter (loads `~/Wallpapers/cats.png`).
- **[SwayOSD](https://github.com/ErikReider/SwayOSD)** — GTK on-screen display for volume / brightness / caps-lock.
- **[greetd](https://sr.ht/~kennylevinsen/greetd/) + [tuigreet](https://github.com/apognu/tuigreet)** — login manager on VT1; the only password prompt at boot (the LUKS root is unlocked by TPM2). `linux/greetd/.config/greetd/` holds `config.toml` and the `banner.txt` greeting; `scripts/first-run/greetd.sh` copies them into `/etc/greetd/`.
- **[uwsm](https://github.com/Vladimir-csp/uwsm)** — Universal Wayland Session Manager, used to launch apps under systemd user scopes.
- **[polkit-gnome](https://gitlab.gnome.org/Archive/policykit-gnome)** — PolicyKit authentication agent for privileged GUI prompts.
- **[fcitx5](https://fcitx-im.org/)** — input method framework (multilingual typing).
- **[qt6-wayland](https://archlinux.org/packages/extra/x86_64/qt6-wayland/)** — native Wayland backend for Qt6 apps (without it they fall back to XWayland despite `QT_QPA_PLATFORM`).
- **[wl-clipboard](https://github.com/bugaevc/wl-clipboard) + [cliphist](https://github.com/sentriz/cliphist)** — clipboard history: `wl-paste --watch cliphist store` runs from `autostart.lua`; `SUPER+V` browses history through Walker's dmenu mode.
- **[playerctl](https://github.com/altdesktop/playerctl)** — MPRIS media-key controller for XF86Audio keys.
- **[brightnessctl](https://github.com/Hummer12007/brightnessctl)** — backlight brightness control used on resume from DPMS off.

On macOS:

- **[AeroSpace](https://github.com/nikitabobko/AeroSpace)** — i3-like tiling window manager. Starts at login, launches SketchyBar, and binds `cmd` + `hjkl` / `1`–`9` for focus, move and workspaces.
- **[SketchyBar](https://github.com/FelixKratz/SketchyBar)** — top status bar; shows AeroSpace workspaces, the front app, clock, volume and battery. Item scripts live in `plugins/`.

## Shell & terminal

- **[Alacritty](https://alacritty.org/)** — GPU-accelerated terminal emulator. Uses MesloLGS Nerd Font (size and family name set per OS in `dotfiles-os`) and a Catppuccin Macchiato palette.
- **[Zsh](https://www.zsh.org/)** — login shell.
- **Zsh plugins** — no plugin manager: `.zshrc` clones each one into `~/.local/share/zsh/plugins` on first start, and `zsh-plugins-update` pulls them.
  - **[Powerlevel10k](https://github.com/romkatv/powerlevel10k)** — prompt, configured via `common/p10k/.p10k.zsh`.
  - **[fzf-tab](https://github.com/Aloxaf/fzf-tab)** — TAB completion menu in fzf.
  - **[zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)** — greyed-out suggestion from history; Right or End accepts it.
  - **[zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)** — colors the command line as you type.
  - **[zsh-history-substring-search](https://github.com/zsh-users/zsh-history-substring-search)** — Up / Down search history for what's already typed.
  - **[zsh-completions](https://github.com/zsh-users/zsh-completions)** — extra completion definitions (e.g. `mvn`, `node`, `openssl`, `ufw`).
- **[zoxide](https://github.com/ajeetdsouza/zoxide)** — frecency-based directory jumper: `z <query>`, or `zi` to pick with fzf.
- **[fnm](https://github.com/Schniz/fnm)** — fast Node.js version manager, with `--use-on-cd`.
- **[SDKMAN](https://sdkman.io/)** (macOS) — JDK version manager. `macos/sdkman` tracks `~/.sdkman/etc/config`: auto-env is on, so `cd` into a project with a `.sdkmanrc` switches Java. The healthcheck is off, because it adds a network request to every `sdk` call, including the auto-env one at shell start and on `cd`.
- **[direnv](https://direnv.net/)** — per-directory environment variables via `.envrc`; hooked in when installed.
- **[fzf](https://github.com/junegunn/fzf)** — fuzzy finder; `Ctrl+R` history, `Ctrl+T` files, `Alt+C` cd. Color palette overridden to match Catppuccin Macchiato.
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

- **[yazi](https://github.com/sxyzxun/yazi)** — blazing-fast terminal file manager, bound to `SUPER+F` and wrapped by a `y` shell function that CDs to its last directory. Also the XDG default for folders (`linux/applications/…/yazi-open.desktop`) and the system file picker. Themed with the Catppuccin Macchiato flavor (pinned in `package.toml`; restore with `ya pkg install`).
- **[btop](https://github.com/aristocratos/btop)** — resource monitor, bound to `SUPER+T`.
- **[lazydocker](https://github.com/jesseduffield/lazydocker)** — TUI for Docker, bound to `SUPER+D`.
- **[pamixer](https://github.com/cdemoulins/pamixer)** — PulseAudio volume CLI used by the Waybar audio module.
- **[gum](https://github.com/charmbracelet/gum)** — interactive TUI prompts used by `tz-select.sh` (styled via `GUM_*` vars in `envs.lua`).
- **[jq](https://jqlang.org/)** — JSON query tool used in scripts (e.g. `launch-or-focus.sh`) to parse `hyprctl` output.
- **[Obsidian](https://obsidian.md/)** — markdown notes app (`SUPER+O`).
- **[Signal](https://signal.org/)** — messaging app (`SUPER+G`).

## Scripts & systemd units

- `scripts/` — helper shell scripts (launchers, battery monitor, screen lock, timezone picker, terminal CWD reporter). The `scripts/README.md` describes copying them into `~/.local/bin/`.
- `linux/systemd/.config/systemd/user/` — user units:
  - `battery-monitor.service` / `.timer` — periodic low-battery notifier.
  - `elephant.service` — keeps the Elephant data provider running for Walker.
- `linux/applications/.local/share/applications/` — custom desktop entries (`yazi-open.desktop`, the `inode/directory` handler set by `scripts/first-run/mimetypes.sh`).
- `linux/portals/.config/` — `xdg-desktop-portal/hyprland-portals.conf` (sends FileChooser to termfilechooser) and `xdg-desktop-portal-termfilechooser/config` (yazi wrapper + terminal). Installed by `scripts/first-run/file-chooser.sh`.
- `scripts/first-run/` — one-time system setup. The boot chain (`network-online.sh`, `uki.sh`, `secure-boot.sh`, `tpm-unlock.sh`, `greetd.sh`) sets up a signed [systemd-boot](https://wiki.archlinux.org/title/Systemd-boot) + [UKI](https://wiki.archlinux.org/title/Unified_kernel_image), [sbctl](https://github.com/Foxboron/sbctl) Secure Boot keys and a TPM2-unlocked LUKS root ([systemd-cryptenroll](https://wiki.archlinux.org/title/Systemd-cryptenroll)), so the greetd login is the only password at boot; order and reboots are in `scripts/first-run/README.md`. On macOS, `scripts/first-run/macos.sh` offers to install the apps and tools the dotfiles call, then applies the system settings AeroSpace and SketchyBar rely on.
- `common/themes/` — extra app themes (currently a qBittorrent Iceberg theme).
