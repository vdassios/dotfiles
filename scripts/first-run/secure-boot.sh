#!/bin/bash

# Boot chain 2/4 — Secure Boot with our own keys (sbctl). Run after uki.sh.
#
# Run it twice; it picks the step from the firmware state:
#   1. Firmware in Setup Mode  → create + enroll keys, sign boot files.
#                                Then enable Secure Boot in firmware and re-run.
#   2. Secure Boot enabled     → re-check signatures, remove the unsigned
#                                fallback loader entries. Then run tpm-unlock.sh.
#
# Signing is kept up to date automatically afterwards: sbctl's pacman hook
# re-signs on package updates and its mkinitcpio post hook signs the new UKI.
#
# NEVER sign /boot/vmlinuz-linux: a signed bare kernel + an editable loader
# entry would let anyone change the cmdline and still get the disk unlocked by
# the TPM. `sbctl verify` reporting it as unsigned is expected.
set -euo pipefail

uki=/boot/EFI/Linux/arch-linux.efi
sdboot=/usr/lib/systemd/boot/efi/systemd-bootx64.efi
fwupd=/usr/lib/fwupd/efi/fwupdx64.efi

sudo pacman -S --needed sbctl jq
sudo test -f "$uki" || { echo "$uki missing — run uki.sh first" >&2; exit 1; }

state=$(sudo sbctl status --json)
setup_mode=$(jq -r .setup_mode <<<"$state")
secure_boot=$(jq -r .secure_boot <<<"$state")
keys_created=$(jq -r .installed <<<"$state")

sign_boot_files() {
  # Sign systemd-boot at its source so bootctl install/update (and
  # systemd-boot-update.service) always copy a signed binary to the ESP.
  sudo sbctl sign -s -o "$sdboot.signed" "$sdboot"
  sudo bootctl install
  sudo sbctl sign -s "$uki"
  # fwupd's capsule updater must be signed too, or firmware updates fail under Secure Boot
  [ -f "$fwupd" ] && sudo sbctl sign -s -o "$fwupd.signed" "$fwupd"
  sudo sbctl verify || true
}

if [ "$setup_mode" = true ]; then
  [ "$keys_created" = true ] || sudo sbctl create-keys
  # -m: keep Microsoft's keys too — firmware option ROMs are signed with them
  sudo sbctl enroll-keys -m
  sign_boot_files
  cat <<'EOF'

Keys enrolled and boot files signed.
Next: systemctl reboot --firmware-setup → enable Secure Boot, save, boot → re-run secure-boot.sh
EOF

elif [ "$secure_boot" = true ] && [ "$keys_created" = true ]; then
  sign_boot_files
  # Type #1 entries boot the bare (unsigned) kernel — useless under Secure Boot.
  sudo find /boot/loader/entries -name '*.conf' -print -delete 2>/dev/null || true
  sudo find /boot -maxdepth 1 -name 'initramfs-*.img' -print -delete
  bootctl status 2>/dev/null | grep 'Secure Boot' || true
  echo
  echo "Secure Boot active with our keys. Next: tpm-unlock.sh"

else
  cat >&2 <<'EOF'
Firmware is not in Setup Mode (and Secure Boot is not active with sbctl keys).
Run: systemctl reboot --firmware-setup
     → Security → Secure Boot → "Erase all Secure Boot Settings", save, boot
     → re-run secure-boot.sh
EOF
  exit 1
fi
