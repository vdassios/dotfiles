#!/bin/bash

# Boot chain 1/4 — boot a signed-able Unified Kernel Image (UKI) via systemd-boot.
#
# Bundles kernel + initramfs + kernel cmdline into /boot/EFI/Linux/arch-linux.efi
# so Secure Boot (secure-boot.sh) can sign the whole thing and the cmdline can't
# be edited at boot. Also: silent boot (nothing printed over the greeter on VT1),
# no boot-menu delay (hold Space at power-on to show it), root-only ESP.
#
# Safe to re-run: every file below is rewritten, not appended to.
# Assumes: ESP at /boot, LUKS2 root opened by the systemd initramfs (sd-encrypt).
set -euo pipefail

# --- preconditions ----------------------------------------------------------
[ "$(findmnt -no FSTYPE /boot)" = vfat ] || { echo "ESP must be mounted at /boot" >&2; exit 1; }
grep -Eq '^HOOKS=\(.*\bsystemd\b.*\bsd-encrypt\b' /etc/mkinitcpio.conf || {
  echo "mkinitcpio HOOKS must use the systemd initramfs (systemd ... sd-encrypt), e.g.:" >&2
  echo "  HOOKS=(base systemd autodetect microcode keyboard keymap sd-vconsole modconf kms block sd-encrypt filesystems fsck)" >&2
  exit 1
}

# tpm2-tss: lets sd-encrypt unlock via TPM2 (tpm-unlock.sh)
sudo pacman -S --needed tpm2-tss

# --- kernel cmdline, derived from the running system ---------------------------
root_src=$(findmnt -nvo SOURCE /)                       # /dev/mapper/root
mapper=${root_src#/dev/mapper/}
luks_uuid=$(lsblk -nso UUID,FSTYPE "$root_src" | awk '$2=="crypto_LUKS"{print $1; exit}')
subvol=$(findmnt -no OPTIONS / | grep -o 'subvol=[^,]*' | sed 's|subvol=/*|subvol=|' || true)
[ -n "$luks_uuid" ] || { echo "root ($root_src) is not on a LUKS volume" >&2; exit 1; }

# quiet/loglevel/show_status: keep kernel + systemd output off the greeter's VT.
echo "rd.luks.name=$luks_uuid=$mapper rd.luks.options=discard,tpm2-device=auto root=$root_src ${subvol:+rootflags=$subvol }rw quiet loglevel=3 rd.udev.log_level=3 systemd.show_status=auto" |
  sudo tee /etc/kernel/cmdline

# --- mkinitcpio: build only the UKI ------------------------------------------
sudo tee /etc/mkinitcpio.d/linux.preset >/dev/null <<'EOF'
# mkinitcpio preset for 'linux' — UKI only (written by dotfiles scripts/first-run/uki.sh)
ALL_kver="/boot/vmlinuz-linux"
PRESETS=('default')
default_uki="/boot/EFI/Linux/arch-linux.efi"
EOF

# --- ESP: root-only (bootctl warns about a world-readable random seed) -------
sudo sed -i -E '/[[:space:]]\/boot[[:space:]]+vfat/ { s/fmask=[0-7]+/fmask=0077/; s/dmask=[0-7]+/dmask=0077/ }' /etc/fstab
grep -E '[[:space:]]/boot[[:space:]]' /etc/fstab | grep -q 'fmask=0077' ||
  echo "WARNING: add fmask=0077,dmask=0077 to the /boot line in /etc/fstab by hand" >&2
sudo systemctl daemon-reload
sudo umount /boot && sudo mount /boot

# --- systemd-boot -------------------------------------------------------------
sudo bootctl is-installed >/dev/null 2>&1 || sudo bootctl install
# editor no: the cmdline can't be changed from the boot menu (would bypass TPM unlock)
printf 'default arch-linux.efi\ntimeout 0\neditor no\n' | sudo tee /boot/loader/loader.conf >/dev/null

sudo mkdir -p /boot/EFI/Linux
sudo mkinitcpio -P
sudo ls -l /boot/EFI/Linux/arch-linux.efi

cat <<'EOF'

UKI built. Old loader entries are kept as a fallback until secure-boot.sh removes them
(hold Space at power-on for the boot menu).

Next: systemctl reboot --firmware-setup
      → Security → Secure Boot → "Erase all Secure Boot Settings" (Setup Mode), save, boot
      → run secure-boot.sh
EOF
