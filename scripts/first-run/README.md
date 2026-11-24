# First-run scripts

Run each of these scripts once on a new machine. Most of them change system
files with `sudo`, so read a script before you run it.

You don't need to copy them anywhere. Make them executable, then run them from
the repository in Zsh. Some have no `#!` line and rely on Zsh to run them.

```sh
chmod +x ~/dotfiles/scripts/first-run/*.sh
~/dotfiles/scripts/first-run/firewall.sh
```

## macOS

`macos.sh` is the only script for macOS. On a new Mac, run it before anything
else, then run `./stow-dotfiles.sh` and log out. The script:

- Installs Homebrew if it's missing. It asks before it does this.
- Lists every app, font and tool the dotfiles use that isn't installed yet,
  then asks whether to install all of them, pick them one by one, or skip
  them. The list includes AeroSpace, SketchyBar, Alacritty, Chrome, Claude
  Code, the Hack and MesloLGS NF fonts, Node through fnm, SDKMAN and tpm.
  SDKMAN is installed so that it doesn't edit your `.zshrc` or replace
  `~/.sdkman/etc/config`, because both of those come from this repository.
- Stops the SketchyBar Homebrew service, because AeroSpace starts the bar
  itself.
- Changes the system settings this setup depends on. Spaces span all
  displays, Mission Control groups windows by app, the Dock and the menu bar
  hide automatically, `Ctrl+Cmd` drags a window from anywhere inside it, keys
  repeat quickly and dark mode is on.

It's safe to run `macos.sh` again.

## Arch Linux: boot and login

These five scripts set up the boot chain. When they're done, the TPM chip
unlocks the encrypted disk without a passphrase, and the greetd login screen
is the only password you type at boot. The TPM only unlocks the disk while
Secure Boot is on and uses your own keys.

Run the scripts in this order, and reboot where the table says to. Each script
checks that the previous step is done, and tells you what to do next.

| Step | Script | What to do after it |
| --- | --- | --- |
| 0 | `network-online.sh` | Nothing. This step is independent of the others. |
| 1 | `uki.sh` | Run `systemctl reboot --firmware-setup`. In the firmware, open **Security**, choose **Secure Boot**, then choose **Erase all Secure Boot Settings**. Boot back into Arch. |
| 2 | `secure-boot.sh` | Run `systemctl reboot --firmware-setup` and **turn on Secure Boot**. Boot back into Arch and run `secure-boot.sh` **a second time**. |
| 3 | `tpm-unlock.sh` | Write down the recovery key. The script shows it only once. |
| 4 | `greetd.sh` | Reboot. Don't restart greetd from inside Hyprland, because that ends your session. |

The old automatic login keeps working until step 4, so you can keep this file
open in Hyprland between reboots.

### What each script changes

- `network-online.sh` stops the boot from waiting two minutes for a network
  that isn't plugged in. It tells systemd the network is online as soon as any
  connection works.
- `uki.sh` builds a unified kernel image: one file that holds the kernel, the
  initramfs and the kernel command line. It writes:
  - `/etc/kernel/cmdline`, generated from your current disk layout. It
    includes `quiet loglevel=3` so that boot messages don't cover the login
    screen.
  - `/etc/mkinitcpio.d/linux.preset`, which builds only the unified image, at
    `/boot/EFI/Linux/arch-linux.efi`.
  - `/boot/loader/loader.conf`, which hides the boot menu (`timeout 0`) and
    stops anyone from editing the boot options (`editor no`).

  It also sets `fmask=0077` and `dmask=0077` on `/boot` in `/etc/fstab`, so
  only root can read the boot partition.
- `secure-boot.sh` creates your own Secure Boot keys with `sbctl` and stores
  them in `/var/lib/sbctl`. It enrolls them alongside Microsoft's keys, then
  signs systemd-boot, the unified image and, if it's installed, `fwupd`. On its
  second run, with Secure Boot on, it removes the old unsigned boot entries and
  initramfs files.
- `tpm-unlock.sh` adds two ways to unlock the disk: a recovery key, and the
  TPM bound to PCR 7 (the Secure Boot state). Your passphrase still works as a
  fallback.
- `greetd.sh` copies `config.toml` and the login banner from
  `linux/greetd/.config/greetd/` into `/etc/greetd/`. Run it again whenever you
  change either file.

### Rules and recovery

- **Never sign `/boot/vmlinuz-linux`.** A signed kernel with an editable boot
  entry lets anyone change the kernel command line, for example to
  `init=/bin/sh`, and the TPM would still unlock the disk. When
  `sbctl verify` reports this file as unsigned, that's expected.
- **To change the kernel command line,** edit `/etc/kernel/cmdline`, then run
  `sudo mkinitcpio -P` to rebuild and re-sign the image. Run
  `sudo sbctl verify` before you reboot, because Secure Boot won't start an
  unsigned image. You don't need to set up the TPM again.
- **If the passphrase prompt comes back,** the Secure Boot state has changed,
  usually after a firmware update, new keys or Secure Boot being turned off and
  on. Type your passphrase, then run `tpm-unlock.sh` again.
- **To open the boot menu,** hold Space while the machine starts.
- **If the login screen doesn't appear,** press `Ctrl+Alt+F2`, log in, and run
  `journalctl -b -u greetd` to see what went wrong.

## Arch Linux: other setup

These scripts are independent of each other. Run the ones you need, in any
order.

| Script | What it does |
| --- | --- |
| `battery-monitor-init.sh` | On a laptop, sets the balanced power profile and turns on the low-battery warning. On a desktop, sets the performance profile. |
| `powerprofilesctl-rules.sh` | Switches the power profile automatically when you plug in or unplug the charger. |
| `detect-keyboard-layout.sh` | Copies the keyboard layout from `/etc/vconsole.conf` into Hyprland's `input.lua`. |
| `dns-resolver.sh` | Points `/etc/resolv.conf` at systemd-resolved. |
| `docker.sh` | Limits the size of Docker's logs and makes containers use the host's DNS. |
| `firewall.sh` | Turns on `ufw`. It blocks incoming connections, except for LocalSend and DNS from Docker containers. |
| `fast-shutdown.sh` | Makes shutdown wait at most five seconds for each service to stop. |
| `increase-lockout-limit.sh` | Locks you out for two minutes after ten wrong passwords, instead of the default three. |
| `elephant.sh` | Starts the Elephant service that Walker needs. |
| `walker-elephant.sh` | Starts Walker at login, and restarts it after each Walker upgrade. |
| `file-chooser.sh` | Installs the yazi file picker for "Open file" and "Save as" dialogs. |
| `mimetypes.sh` | Sets the default apps: yazi for folders, imv for images, mpv for videos, Evince for PDFs and Chromium for links. |
| `gnome-theme.sh` | Sets dark mode and the Yaru icon theme for GTK apps. |
| `theme.sh` | Replaces two Yaru icons with Adwaita's, and makes Chromium's and Brave's policy folders writable so their theme can change without `sudo`. |
