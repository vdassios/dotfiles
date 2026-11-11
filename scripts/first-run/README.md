### Run each script only once on every clean install with `first-run.sh`

Make sure they are executable

### macOS

`macos.sh` is the only macOS script. Run it first on a new Mac, then
`./stow-dotfiles.sh`, then log out. It:

- installs Homebrew if it's missing (asks first) and trusts the AeroSpace and
  SketchyBar taps;
- lists every app, font and tool the dotfiles call that isn't installed yet
  (CLI tools, AeroSpace, SketchyBar, Alacritty, Chrome, Claude Code, the Hack
  and MesloLGS NF fonts, Node via fnm, SDKMAN, tpm) and asks: all, one by one,
  or none. SDKMAN's installer is kept from editing the stowed `.zshrc` and
  `~/.sdkman/etc/config`;
- stops the SketchyBar Homebrew service (AeroSpace launches the bar);
- writes the `defaults` the setup depends on: Spaces span displays, Mission
  Control groups by app, the Dock stays hidden, the menu bar auto-hides,
  ctrl+cmd drags windows, fast key repeat, dark mode.

### Boot chain: TPM-unlocked disk + greetd login

Goal: no LUKS passphrase prompt; the disk is unlocked by the TPM2 chip (only
while Secure Boot is on with our own keys), and the tuigreet login on VT1 is
the only password at boot. Order matters — each script checks its
preconditions and prints the next step. Reboots in between are required.

| # | Script | Then |
|---|--------|------|
| 0 | `network-online.sh` | (independent; stops the 2-min `wait-online` hang from an unplugged `br0`) |
| 1 | `uki.sh` | `systemctl reboot --firmware-setup` → Security → Secure Boot → **Erase all Secure Boot Settings** → boot |
| 2 | `secure-boot.sh` | `systemctl reboot --firmware-setup` → **enable Secure Boot** → boot → run `secure-boot.sh` **again** |
| 3 | `tpm-unlock.sh` | write down the recovery key it prints (once) |
| 4 | `greetd.sh` | `reboot` (don't restart greetd from inside Hyprland — it kills the session) |

After step 1, `less` this file from Hyprland between reboots — the old
greetd autologin stays active until step 4.

What each step leaves behind:

- `uki.sh` — `/etc/kernel/cmdline` (generated from the running root/LUKS
  layout; includes `quiet loglevel=3 …` so nothing prints over the greeter),
  `/etc/mkinitcpio.d/linux.preset` (UKI only → `/boot/EFI/Linux/arch-linux.efi`),
  `/boot/loader/loader.conf` (`timeout 0`, `editor no`), ESP mounted `fmask=0077`.
- `secure-boot.sh` — sbctl keys in `/var/lib/sbctl`, enrolled with Microsoft's
  (`-m`); signed systemd-boot, UKI and (if installed) fwupd. Removes the old
  unsigned loader entries + loose initramfs once Secure Boot is on.
- `tpm-unlock.sh` — LUKS keyslots: passphrase (kept as fallback) + recovery
  key + TPM2 bound to PCR 7.
- `greetd.sh` — `/etc/greetd/config.toml` and `/etc/greetd/banner` from the
  `greetd` Stow package.

Rules / recovery:

- **Never sign `/boot/vmlinuz-linux`.** A signed bare kernel plus an editable
  loader entry = edit the cmdline (`init=/bin/sh`), TPM still unlocks.
  `sbctl verify` showing it unsigned is expected.
- **Kernel cmdline changes** go in `/etc/kernel/cmdline`, then `sudo mkinitcpio -P`
  (sbctl's hook re-signs the UKI) and `sudo sbctl verify` before rebooting —
  an unsigned UKI won't boot with Secure Boot on. No TPM re-enroll needed.
- **Passphrase prompt is back** (firmware/dbx update, keys changed, Secure Boot
  toggled): type the passphrase, then re-run `tpm-unlock.sh`.
- **Boot menu**: hold Space at power-on.
- **Greeter broken**: Ctrl+Alt+F2, log in, `journalctl -b -u greetd`.
