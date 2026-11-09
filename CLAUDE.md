# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository layout (GNU Stow, split by OS)

The dotfiles serve two machines: an Arch Linux desktop and a macOS MacBook Air. Stow packages are grouped into three stow directories:

- `common/` — packages for both OSes (alacritty, nvim, p10k, themes, tmux, yazi, zsh).
- `linux/` — Arch-only packages (hypr, waybar, walker, mako, greetd, portals, systemd, applications) and `dotfiles-os`.
- `macos/` — macOS-only packages (aerospace, sketchybar) and `dotfiles-os`.

Each package's internal layout mirrors `$HOME`. For example, `linux/hypr/.config/hypr/hyprland.lua` ends up at `~/.config/hypr/hyprland.lua`. `./stow-dotfiles.sh` restows every package in `common/` plus the current OS's folder. "Deploying" a change means re-running it. There is no Makefile or test suite.

Rules when adding or changing configs:

- **Pick the folder by OS.** A tool used on both machines goes in `common/`, even if one or two values differ. Put a tool in `linux/` or `macos/` only if it exists on just that OS. Never put macOS-only values (paths, font names, sizes) in a `common/` file or the Arch machine breaks, and vice versa.
- **Per-OS values go in `dotfiles-os`.** `linux/dotfiles-os` and `macos/dotfiles-os` both provide `~/.config/dotfiles-os/`. Common configs include files from there: `alacritty.toml` is imported by alacritty and must hold `[font]`, because imports load before the main file and the main file would override them. `zshrc.zsh` is sourced at the very end of `.zshrc` (SDKMAN must be last). When a new per-OS value is needed, add it to **both** OS fragments.
- **No package in `linux/` or `macos/` may share a target directory with a `common/` package.** Stow can't merge one directory across two stow directories and aborts with "existing target is not owned by stow". That's why the fragments live in `~/.config/dotfiles-os/` and not in e.g. `~/.config/alacritty/`.

Two directories break the Stow pattern and need manual handling:

- `scripts/` — **not** a Stow package. Per `scripts/README.md`, these `.sh` files must be copied (or symlinked) into `~/.local/bin/` by hand and made executable. Many Hyprland keybindings and systemd units invoke these by basename, so renaming a script requires updating its consumers (grep `linux/hypr/.config/hypr/bindings.lua` and `linux/systemd/.config/systemd/user/*.service`).
- `common/zsh/` — ships `.zshrc` at the package root (not under `.config/`), because z4h expects `~/.zshrc`. The vendored `zsh-z.plugin.zsh` is sourced from `$HOME/zsh-z.plugin.zsh` in `.zshrc:129`, so it lives at `$HOME`, not `~/.config/`.

## Cross-file wiring to watch

Configs here are not self-contained — several form chains where a change in one file silently requires a matching change elsewhere:

- **Hyprland (Lua config, 0.57+)** — Hyprland dropped the hyprlang `.conf` format in 0.57; the config is now Lua. `hyprland.lua` is a thin file that `require`s seven siblings (`envs`, `monitors`, `input`, `looknfeel`, `windows`, `bindings`, `autostart` — each `<name>.lua`). New Hyprland settings go in the appropriate split file, not `hyprland.lua`. Each `require` is its own scope, so locals are not shared between files. API reference: the wiki plus the type stubs in `/usr/share/hypr/stubs/`. Autostart uses `hl.on("hyprland.start", ...)` (fires on login, not on `hyprctl reload`). The other hypr* tools (`hyprlock.conf`, `hypridle.conf`, `hyprsunset.conf`, `xdph.conf`, and the `catppuccin_macchiato.conf` palette hyprlock sources) still use hyprlang.
- **`hyprctl dispatch` syntax** — under the Lua config, `hyprctl dispatch` takes a Lua dispatcher expression, e.g. `hyprctl dispatch 'hl.dsp.dpms({ action = "disable" })'`. The old `hyprctl dispatch dpms off` form errors out. Scripts and `hypridle.conf` must use the new form.
- **Walker / Elephant** — Walker (the launcher) depends on the Elephant data-provider daemon, which is kept alive by `linux/systemd/.config/systemd/user/elephant.service`. A broken launcher is often an Elephant problem, not a Walker config problem.
- **Waybar ↔ scripts** — Waybar modules shell out to scripts in `~/.local/bin/` (e.g. `launch-audio.sh`, `launch-bluetooth.sh`, `launch-wifi.sh`, `powerprofiles-list.sh`). Check `linux/waybar/.config/waybar/config.jsonc` for the exact `on-click` commands before renaming scripts.
- **File manager / file picker (yazi)** — folders open via `linux/applications/.local/share/applications/yazi-open.desktop` (→ `launch-tui yazi`), made the `inode/directory` default in `scripts/first-run/mimetypes.sh`. "Open/Save as" dialogs go through `linux/portals/` (portal routing + termfilechooser config), which launches the terminal with app-id `yazi-filechooser`; `linux/hypr/.config/hypr/windows.lua` floats that app-id. Keep the app-id in sync between the two.
- **Boot chain (systemd-boot → signed UKI → TPM2 LUKS unlock → greetd)** — set up by `scripts/first-run/{uki,secure-boot,tpm-unlock,greetd}.sh` in that order (see `scripts/first-run/README.md`). The kernel cmdline lives in `/etc/kernel/cmdline` and is baked into `/boot/EFI/Linux/arch-linux.efi`; changing it needs `mkinitcpio -P` + `sbctl verify`. The TPM is bound to PCR 7 only. Never sign `/boot/vmlinuz-linux` or add type #1 loader entries — that bypasses the TPM unlock. greetd's config is copied to `/etc/greetd/` (not stowed) because the `greeter` user can't read `$HOME`; edit `linux/greetd/.config/greetd/` and re-run `greetd.sh`.
- **AeroSpace ↔ SketchyBar** — AeroSpace launches SketchyBar (`after-startup-command`) and fires the custom `aerospace_workspace_change` event with `FOCUSED_WORKSPACE` on every workspace switch (`exec-on-workspace-change`). `sketchybarrc` registers that event and builds one `space.<id>` item per `aerospace list-workspaces --all`; `plugins/aerospace.sh` highlights the focused one. Keep the event name and variable in sync between `macos/aerospace/.config/aerospace/aerospace.toml` and `macos/sketchybar/.config/sketchybar/`.
- **Battery monitor** — `battery-monitor.service` + `.timer` (systemd user units) drive `scripts/battery-monitor.sh`. All three must stay in sync.
- **Neovim (kickstart-based)** — `init.lua` is minimal; it requires `options`, `keymaps`, `lazy-bootstrap`, then `lazy-plugins`. Actual plugin specs live in `common/nvim/.config/nvim/lua/plugins/*.lua` and are auto-discovered by lazy.nvim. Add a new plugin by dropping a new file in that directory; do not edit `lazy-plugins.lua` to register it. The pinned versions live in `lazy-lock.json` — commit lockfile changes alongside plugin changes.

## Conventions

- **Theme** — Catppuccin Macchiato is the active palette across Alacritty, Hyprlock (`catppuccin_macchiato.conf`), fzf (`FZF_DEFAULT_OPTS` in `.zshrc`), Neovim (`catppuccin.lua`), Waybar, and tmux (inline hex in `tmux.conf`). Match these hexes when adding new themed surfaces rather than introducing a fresh palette.
- **Shell scripts** are POSIX-ish bash with `.sh` extensions, invoked by basename from Hyprland/Waybar/systemd. Keep them self-contained and executable.
- **No secrets, no machine-specific state** — `linux/hypr/.config/hypr/monitors.lua` is host-specific; prefer not to commit host-specific churn. Per `.zshrc:88`, machine-local overrides go in `~/.env.zsh` (not tracked). OS-wide differences go in `dotfiles-os` instead.

## README

The repo's `README.md` is the canonical inventory of every tool in use (compositor, bar, launcher, shell plugins, Neovim plugins, system utilities, scripts, systemd units) with upstream links. When asked "what does X do" or "why is Y here," check `README.md` first — it's kept current and will usually answer without needing to read the config.
