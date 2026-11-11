#!/usr/bin/env bash
# Symlink the dotfiles into $HOME with GNU Stow: every package in common/,
# plus every package in the folder for this OS (linux/ or macos/).
# Safe to re-run; it restows, so links to deleted files are cleaned up.
set -euo pipefail

repo=$(cd "$(dirname "$0")" && pwd)

case "$OSTYPE" in
  darwin*) os=macos ;;
  linux*)  os=linux ;;
  *) echo "stow-dotfiles: unsupported OSTYPE '$OSTYPE'" >&2; exit 1 ;;
esac

# Make sure shared parent directories exist as real directories. Otherwise
# stow "folds" them, e.g. ~/.config itself becomes a symlink into the first
# package and every app's config lands in this repo.
mkdir -p "$HOME/.config"
[[ $os == linux ]] && mkdir -p "$HOME/.local/share/applications"
[[ $os == macos ]] && mkdir -p "$HOME/.sdkman/etc"

for dir in common "$os"; do
  cd "$repo/$dir"
  pkgs=(*/)
  stow --restow --target="$HOME" "${pkgs[@]%/}"
  echo "stowed $dir: ${pkgs[*]%/}"
done
