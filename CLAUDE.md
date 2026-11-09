# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository layout (GNU Stow-style)

Each top-level directory is a Stow package whose internal layout mirrors `$HOME`. For example, `hypr/.config/hypr/hyprland.lua` is meant to end up at `~/.config/hypr/hyprland.lua`. When adding a new config file, create the full `<pkg>/.config/<app>/...` (or `<pkg>/.<file>`) path under the appropriate package so `stow <pkg>` from the repo root would place it correctly. There is no Makefile, installer, or test suite — "deploying" a change means re-symlinking with Stow (or manually) onto the live system.

Two packages break the Stow pattern and need manual handling:

- `scripts/` — **not** a Stow package. Per `scripts/README.md`, these `.sh` files must be copied (or symlinked) into `~/.local/bin/` by hand and made executable. Many Hyprland keybindings and systemd units invoke these by basename, so renaming a script requires updating its consumers (grep `hypr/.config/hypr/bindings.lua` and `systemd/.config/systemd/user/*.service`).
- `zsh/` — ships `.zshrc` at the package root (not under `.config/`), because z4h expects `~/.zshrc`. The vendored `zsh-z.plugin.zsh` is sourced from `$HOME/zsh-z.plugin.zsh` in `.zshrc:131`, so it lives at `$HOME`, not `~/.config/`.

## Cross-file wiring to watch

Configs here are not self-contained — several form chains where a change in one file silently requires a matching change elsewhere:

- **Hyprland (Lua config, 0.57+)** — Hyprland dropped the hyprlang `.conf` format in 0.57; the config is now Lua. `hyprland.lua` is a thin file that `require`s seven siblings (`envs`, `monitors`, `input`, `looknfeel`, `windows`, `bindings`, `autostart` — each `<name>.lua`). New Hyprland settings go in the appropriate split file, not `hyprland.lua`. Each `require` is its own scope, so locals are not shared between files. API reference: the wiki plus the type stubs in `/usr/share/hypr/stubs/`. Autostart uses `hl.on("hyprland.start", ...)` (fires on login, not on `hyprctl reload`). The other hypr* tools (`hyprlock.conf`, `hypridle.conf`, `hyprsunset.conf`, `xdph.conf`, and the `catppuccin_macchiato.conf` palette hyprlock sources) still use hyprlang.
- **`hyprctl dispatch` syntax** — under the Lua config, `hyprctl dispatch` takes a Lua dispatcher expression, e.g. `hyprctl dispatch 'hl.dsp.dpms({ action = "disable" })'`. The old `hyprctl dispatch dpms off` form errors out. Scripts and `hypridle.conf` must use the new form.
- **Walker / Elephant** — Walker (the launcher) depends on the Elephant data-provider daemon, which is kept alive by `systemd/.config/systemd/user/elephant.service`. A broken launcher is often an Elephant problem, not a Walker config problem.
- **Waybar ↔ scripts** — Waybar modules shell out to scripts in `~/.local/bin/` (e.g. `launch-audio.sh`, `launch-bluetooth.sh`, `launch-wifi.sh`, `powerprofiles-list.sh`). Check `waybar/.config/waybar/config.jsonc` for the exact `on-click` commands before renaming scripts.
- **File manager / file picker (yazi)** — folders open via `applications/.local/share/applications/yazi-open.desktop` (→ `launch-tui yazi`), made the `inode/directory` default in `scripts/first-run/mimetypes.sh`. "Open/Save as" dialogs go through `portals/` (portal routing + termfilechooser config), which launches the terminal with app-id `yazi-filechooser`; `hypr/.config/hypr/windows.lua` floats that app-id. Keep the app-id in sync between the two.
- **Battery monitor** — `battery-monitor.service` + `.timer` (systemd user units) drive `scripts/battery-monitor.sh`. All three must stay in sync.
- **Neovim (kickstart-based)** — `init.lua` is minimal; it requires `options`, `keymaps`, `lazy-bootstrap`, then `lazy-plugins`. Actual plugin specs live in `nvim/.config/nvim/lua/plugins/*.lua` and are auto-discovered by lazy.nvim. Add a new plugin by dropping a new file in that directory; do not edit `lazy-plugins.lua` to register it. The pinned versions live in `lazy-lock.json` — commit lockfile changes alongside plugin changes.

## Conventions

- **Theme** — Catppuccin Macchiato is the active palette across Alacritty, Hyprlock (`catppuccin_macchiato.conf`), fzf (`FZF_DEFAULT_OPTS` in `.zshrc`), Neovim (`catppuccin.lua`), Waybar, and tmux (inline hex in `tmux.conf`). Match these hexes when adding new themed surfaces rather than introducing a fresh palette.
- **Shell scripts** are POSIX-ish bash with `.sh` extensions, invoked by basename from Hyprland/Waybar/systemd. Keep them self-contained and executable.
- **No secrets, no machine-specific state** — `hypr/.config/hypr/monitors.lua` is host-specific; prefer not to commit host-specific churn. Per `.zshrc:87`, machine-local overrides go in `~/.env.zsh` (not tracked).

## README

The repo's `README.md` is the canonical inventory of every tool in use (compositor, bar, launcher, shell plugins, Neovim plugins, system utilities, scripts, systemd units) with upstream links. When asked "what does X do" or "why is Y here," check `README.md` first — it's kept current and will usually answer without needing to read the config.
