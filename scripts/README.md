# Helper scripts

Hyprland, Waybar, systemd and the desktop entries run these scripts by name,
without the `.sh` extension. For example, `Super+Return` runs
`cmd-terminal-cwd`, and the battery service runs `battery-monitor`.

This folder is not a Stow package, so you need to install the scripts by hand
on every new Arch install. Copy each one into `~/.local/bin`, drop the `.sh`
extension and make it executable:

```sh
mkdir -p ~/.local/bin
for script in ~/dotfiles/scripts/*.sh; do
  install -m 755 "$script" ~/.local/bin/"$(basename "$script" .sh)"
done
```

Run the same loop again after you change a script. `.zshrc` and Hyprland's
`envs.lua` already add `~/.local/bin` to your `PATH`.

If you rename a script, update everything that calls it. Search
`linux/hypr/`, `linux/waybar/`, `linux/systemd/` and `linux/applications/` for
the old name.

The scripts in `first-run/` are different: you run each one once on a new
machine. See [`first-run/README.md`](first-run/README.md).
