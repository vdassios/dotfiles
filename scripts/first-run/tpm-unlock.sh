#!/bin/bash

# Boot chain 3/4 — unlock the LUKS root with the TPM2 chip instead of a
# passphrase prompt. Run after secure-boot.sh (Secure Boot must be ON: the
# binding is to PCR 7, the Secure Boot state, so enrolling earlier would bind
# to "Secure Boot off" and protect nothing).
#
# Safe to re-run, and that's the fix when the LUKS passphrase prompt comes
# back (firmware/dbx update, Secure Boot keys changed or toggled): type the
# passphrase, then run this again to re-bind. The passphrase slot is kept as a
# fallback; a recovery key is added once.
set -euo pipefail

sudo pacman -S --needed sbctl jq tpm2-tss
[ "$(sudo sbctl status --json | jq -r .secure_boot)" = true ] || {
  echo "Secure Boot is not enabled — finish secure-boot.sh first" >&2; exit 1; }

root_src=$(findmnt -nvo SOURCE /)
luks_uuid=$(lsblk -nso UUID,FSTYPE "$root_src" | awk '$2=="crypto_LUKS"{print $1; exit}')
[ -n "$luks_uuid" ] || { echo "root ($root_src) is not on a LUKS volume" >&2; exit 1; }
dev=/dev/disk/by-uuid/$luks_uuid

if ! sudo systemd-cryptenroll "$dev" | awk '$2=="recovery"{found=1} END{exit !found}'; then
  echo ">>> Recovery key — write it down and keep it OFF this machine:"
  sudo systemd-cryptenroll "$dev" --recovery-key
fi

# Enroll first, then wipe any older tpm2 slot (the new one is never wiped).
sudo systemd-cryptenroll "$dev" --wipe-slot=tpm2 --tpm2-device=auto --tpm2-pcrs=7

sudo systemd-cryptenroll "$dev"   # expect: password, recovery, tpm2
echo
echo "Next: greetd.sh (login prompt replaces the passphrase prompt), then reboot."
