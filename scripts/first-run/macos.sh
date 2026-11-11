#!/bin/bash
# One-time macOS setup: offers to install what the dotfiles call, then applies
# the system settings the AeroSpace + SketchyBar desktop relies on.
# Run before ./stow-dotfiles.sh (which needs stow). Safe to re-run.
# Log out and back in afterwards: Spaces, menu-bar, key-repeat and appearance
# changes only apply at login.
set -euo pipefail

[[ $OSTYPE == darwin* ]] || { echo "macos.sh: macOS only" >&2; exit 1; }

# ---- Homebrew ---------------------------------------------------------------
[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
if ! command -v brew >/dev/null; then
  read -rp "Homebrew is not installed; everything below needs it. Install it? [Y/n] " yn || yn=n
  [[ $yn == [nN]* ]] && exit 1
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Homebrew refuses to load formulae from untrusted third-party taps, and
# `brew upgrade` then skips them without saying so. AeroSpace and SketchyBar
# both come from one.
for tap in nikitabobko/tap felixkratz/formulae; do
  brew tap "$tap"
  brew trust --tap "$tap"
done

# ---- Apps the dotfiles call -------------------------------------------------
labels=() cmds=()
queue()   { labels+=("$1"); cmds+=("$2"); }
formula() { command -v "$1" >/dev/null || queue "$2" "brew install $2"; }  # <binary> <formula>
cask()    { [[ -e $2 ]] || queue "$1" "brew install --cask $1"; }          # <cask> <installed path>

formula stow        stow                          # stow-dotfiles.sh
formula nvim        neovim                        # $EDITOR
formula tmux        tmux
formula fzf         fzf                           # .zshrc widgets, fzf-tab, fzf-lua
formula zoxide      zoxide                        # .zshrc `z`
formula direnv      direnv                        # .zshrc hook
formula yazi        yazi                          # .zshrc `y`
formula rg          ripgrep                       # fzf-lua live grep
formula tree-sitter tree-sitter-cli               # nvim-treesitter (main branch) builds parsers with it
formula hadolint    hadolint                      # nvim-lint, Dockerfiles (not installed by Mason)
formula tree        tree                          # .zshrc alias
formula fnm         fnm                           # .zshrc Node version switching
formula sketchybar  felixkratz/formulae/sketchybar
cask nikitabobko/tap/aerospace     /Applications/AeroSpace.app
cask alacritty                     /Applications/Alacritty.app
cask google-chrome                 "/Applications/Google Chrome.app"  # aerospace cmd-b
cask font-hack-nerd-font           ~/Library/Fonts/HackNerdFont-Regular.ttf    # SketchyBar
cask font-meslo-for-powerlevel10k  ~/Library/Fonts/"MesloLGS NF Regular.ttf"  # Alacritty, p10k
command -v claude >/dev/null || queue claude-code@latest "brew install --cask claude-code@latest"  # common/claude
# .zshrc only sets up fnm once ~/.local/share/fnm exists, and Mason needs npm
# for its LSPs and formatters.
[[ -d ~/.local/share/fnm/node-versions ]]   || queue "Node LTS (via fnm)" "fnm install --lts"
[[ -f ~/.sdkman/bin/sdkman-init.sh ]]       || queue SDKMAN install_sdkman
[[ -d ~/.local/share/tmux/plugins/tpm ]]    || queue "tmux plugin manager" \
  "git clone https://github.com/tmux-plugins/tpm ~/.local/share/tmux/plugins/tpm"

# The installer appends its init snippet to ~/.zshrc and writes
# ~/.sdkman/etc/config; once stowed, both are symlinks into this repo. Send the
# .zshrc edit to a throwaway dir (dotfiles-os/zshrc.zsh already sources SDKMAN)
# and drop the generated config so the tracked one is used.
install_sdkman() {
  local cfg=~/.sdkman/etc/config tmp
  tmp=$(mktemp -d)
  if [[ -L $cfg ]]; then mv "$cfg" "$tmp/config.link"; fi
  curl -fsSL https://get.sdkman.io | ZDOTDIR=$tmp bash
  rm -f "$cfg"
  if [[ -L $tmp/config.link ]]; then mv "$tmp/config.link" "$cfg"; fi
  rm -rf "$tmp"
}

if (( ${#labels[@]} )); then
  echo "Not installed yet:"
  printf '  %s\n' "${labels[@]}"
  read -rp "Install [a]ll, [s]elect one by one, or [n]one? " answer || answer=n
  for i in "${!labels[@]}"; do
    case $answer in
      [aA]*) ;;
      [sS]*) read -rp "Install ${labels[i]}? [y/N] " yn || yn=n
             [[ $yn == [yY]* ]] || continue ;;
      *) break ;;
    esac
    eval "${cmds[i]}" || echo "macos.sh: installing ${labels[i]} failed" >&2
  done
fi

# AeroSpace launches SketchyBar (after-startup-command in aerospace.toml). A
# Homebrew service with KeepAlive started alongside it loses the lock and gets
# respawned by launchd every few seconds, and at login it can beat AeroSpace
# and build the bar before `aerospace list-workspaces` answers.
if [[ -e ~/Library/LaunchAgents/homebrew.mxcl.sketchybar.plist ]]; then
  brew services stop sketchybar
fi

# ---- System settings --------------------------------------------------------
# AeroSpace guide recommendations (https://nikitabobko.github.io/AeroSpace/guide):
# - Turn off "Displays have separate Spaces"; with it on, focus and performance
#   break, especially when an external monitor is plugged in.
defaults write com.apple.spaces spans-displays -bool true
# - Mission Control mishandles the windows AeroSpace parks in the bottom-right
#   corner (hidden workspaces) unless windows are grouped by app.
defaults write com.apple.dock expose-group-apps -bool true
# - Drag any window with ctrl+cmd from anywhere inside it.
defaults write -g NSWindowShouldDragOnGesture -bool true

# Dock stays at the bottom and never pops up over tiled windows; AeroSpace
# parks hidden windows in the bottom corners, which a visible Dock would cover.
defaults write com.apple.dock orientation -string bottom
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 10000

# SketchyBar replaces the menu bar, so always auto-hide it. aerospace.toml's
# gaps.outer.top assumes this.
defaults write -g _HIHideMenuBar -bool true
defaults write com.apple.controlcenter AutoHideMenuBarOption -int 0

# No zoom animation when windows open; AeroSpace resizes them straight away.
defaults write -g NSAutomaticWindowAnimationsEnabled -bool false

# Fast key repeat (KeyRepeat 2 = 30 ms, InitialKeyRepeat 15 = 225 ms).
defaults write -g KeyRepeat -int 2
defaults write -g InitialKeyRepeat -int 15

# Dark mode, to match the Catppuccin Macchiato surfaces.
defaults write -g AppleInterfaceStyle -string Dark

killall Dock SystemUIServer 2>/dev/null || true

echo "Done. Still manual:"
echo "  - Run ./stow-dotfiles.sh if you haven't yet."
echo "  - Open AeroSpace, then System Settings → Privacy & Security → Accessibility: allow it."
echo "  - Log out and back in."
