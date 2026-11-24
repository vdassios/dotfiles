# dotfiles

These are the configuration files for my two machines: an Arch Linux desktop
and a MacBook Air.

- [Installation](#installation)
- [How the repository is organized](#how-the-repository-is-organized)
- [Desktop](#desktop)
- [Shell and terminal](#shell-and-terminal)
- [Neovim](#neovim)
- [Other tools](#other-tools)
- [Scripts and services](#scripts-and-services)

## Installation

The configs are installed with [GNU Stow](https://www.gnu.org/software/stow/),
which links each file into your home directory.

1. Clone the repository into `~/dotfiles`:

   ```sh
   git clone https://github.com/vdassios/dotfiles.git ~/dotfiles
   ```

2. Install Stow. On a Mac, run the setup script instead. It installs Homebrew,
   Stow and the apps these configs use, then changes the system settings that
   AeroSpace and SketchyBar need:

   ```sh
   ~/dotfiles/scripts/first-run/macos.sh
   ```

   On Arch:

   ```sh
   sudo pacman -S stow
   ```

3. Link the configs into your home directory:

   ```sh
   cd ~/dotfiles
   ./stow-dotfiles.sh
   ```

4. On Arch, install the helper scripts as described in
   [`scripts/README.md`](scripts/README.md), then run the one-time setup in
   [`scripts/first-run/README.md`](scripts/first-run/README.md).

5. On a Mac, log out and back in.

To pick up changes after a `git pull`, run `./stow-dotfiles.sh` again. It
relinks every package, so it also removes links to files that no longer exist.

If you install SDKMAN by hand instead of through `macos.sh`, delete the
`~/.sdkman/etc/config` file it creates before you run `./stow-dotfiles.sh`.
Stow won't replace a file that it didn't create.

## How the repository is organized

Each package is a folder whose contents mirror your home directory. For
example, `linux/hypr/.config/hypr/hyprland.lua` is linked to
`~/.config/hypr/hyprland.lua`.

Packages are grouped by the machine they belong to:

- `common/` holds the packages used on both machines: alacritty, claude, nvim,
  p10k, themes, tmux, yazi and zsh.
- `linux/` holds the Arch-only packages: Hyprland, Waybar, Walker, mako,
  greetd, the desktop portals, systemd units and desktop entries.
- `macos/` holds the macOS-only packages: AeroSpace, SDKMAN and SketchyBar.

`stow-dotfiles.sh` links every package in `common/`, plus every package in the
folder for the current OS. The `scripts/` folder is not a package. See
[Scripts and services](#scripts-and-services).

### Settings that differ between machines

A few shared configs need a different value on each machine, such as the font
size in Alacritty. These configs read the value from a file in
`~/.config/dotfiles-os/`. Both `linux/` and `macos/` contain a `dotfiles-os`
package that provides this folder, so each machine gets its own copy.

- Alacritty imports `alacritty.toml`, which sets the font family and size.
- `.zshrc` sources `env.zsh` first, which adds Homebrew to your `PATH` on
  macOS. It sources `zshrc.zsh` last, which sets `JAVA_HOME` and, on macOS,
  loads SDKMAN.

If you need a new per-machine value, add it to both `dotfiles-os` packages.

These files have their own folder because Stow can't fill one folder from two
places. If `common/alacritty` and `linux/alacritty` both put files in
`~/.config/alacritty/`, Stow would stop with an error.

### Adding a new tool

1. Move the tool's config into a new package. Use `linux/` or `macos/` instead
   of `common/` if you only use the tool on one machine:

   ```sh
   mkdir -p ~/dotfiles/common/foo/.config
   mv ~/.config/foo ~/dotfiles/common/foo/.config/
   ```

2. Run `./stow-dotfiles.sh` to link it back into place.

3. Commit the new package.

## Desktop

### Arch Linux

- [Hyprland](https://hypr.land/) is the tiling window manager. Its config is
  written in Lua, which Hyprland requires from version 0.57. `hyprland.lua`
  loads one file per topic: `envs`, `monitors`, `input`, `looknfeel`,
  `windows`, `bindings` and `autostart`.
- [Hypridle](https://github.com/hyprwm/hypridle) locks the screen and turns off
  the display when the machine is idle.
- [Hyprlock](https://github.com/hyprwm/hyprlock) is the lock screen.
- [Hyprsunset](https://github.com/hyprwm/hyprsunset) changes the screen's
  color temperature. It leaves the screen unchanged until you add a night
  profile to `hyprsunset.conf`. Turn it on with
  `systemctl --user enable --now hyprsunset.service`.
- [hyprshutdown](https://github.com/hyprwm/hyprshutdown) closes your apps
  before it powers off the machine. Press `Super+Shift+E` to run it.
- [Hyprshot](https://github.com/Gustash/Hyprshot) takes screenshots of a
  window, a screen or a region. Its shortcuts use the `Print` key.
- [greetd](https://sr.ht/~kennylevinsen/greetd/) and
  [tuigreet](https://github.com/apognu/tuigreet) show the login screen. It's
  the only password prompt at boot, because the TPM chip unlocks the
  encrypted disk. `greetd` can't read your home directory, so its config is
  copied into `/etc/greetd/` instead of linked. After you edit
  `linux/greetd/`, run `scripts/first-run/greetd.sh` again.
- [Waybar](https://github.com/Alexays/Waybar) is the status bar. It shows
  workspaces, the clock, the keyboard layout, Bluetooth, network, audio, CPU
  and battery.
- [Walker](https://github.com/abenz1267/walker) is the app launcher. It also
  searches the web, does math, inserts symbols and browses your clipboard
  history and files.
- [Elephant](https://github.com/abenz1267/elephant) supplies Walker's search
  results and runs as a systemd service. If Walker stops working, check
  Elephant first.
- [Mako](https://github.com/emersion/mako) shows notifications.
- [SwayOSD](https://github.com/ErikReider/SwayOSD) shows a popup when you
  change the volume or brightness, or press Caps Lock.
- [swaybg](https://github.com/swaywm/swaybg) sets the wallpaper from
  `~/Wallpapers/cats.png`.
- [cliphist](https://github.com/sentriz/cliphist) and
  [wl-clipboard](https://github.com/bugaevc/wl-clipboard) keep a clipboard
  history. Press `Super+V` to search it in Walker.
- [xdg-desktop-portal-termfilechooser](https://github.com/hunkyburrito/xdg-desktop-portal-termfilechooser)
  replaces the "Open file" and "Save as" dialogs with yazi in a floating
  terminal. It works in Chromium, Firefox and GTK apps. Install it from the
  AUR.
- [xdg-desktop-portal-hyprland](https://github.com/hyprwm/xdg-desktop-portal-hyprland)
  handles screen sharing.
- [uwsm](https://github.com/Vladimir-csp/uwsm) starts apps as systemd units,
  so each one can be tracked and stopped on its own.
- [polkit-gnome](https://gitlab.gnome.org/Archive/policykit-gnome) asks for
  your password when an app needs admin rights.
- [fcitx5](https://fcitx-im.org/) lets you type in other languages.
- [qt6-wayland](https://archlinux.org/packages/extra/x86_64/qt6-wayland/)
  lets Qt 6 apps run natively on Wayland. Without it, they fall back to
  XWayland.
- [playerctl](https://github.com/altdesktop/playerctl) makes the media keys
  control whichever player is active.
- [brightnessctl](https://github.com/Hummer12007/brightnessctl) restores the
  screen brightness when the display wakes up.

### macOS

- [AeroSpace](https://github.com/nikitabobko/AeroSpace) is the tiling window
  manager. It starts at login and launches SketchyBar. Press `Cmd` with
  `H`, `J`, `K` or `L` to move focus, and add `Shift` to move the window.
  Press `Cmd` with a number to switch workspaces.
- [SketchyBar](https://github.com/FelixKratz/SketchyBar) is the status bar. It
  shows workspaces, the active app, the clock, volume and battery. The script
  behind each item is in `plugins/`.

## Shell and terminal

- [Alacritty](https://alacritty.org/) is the terminal. It uses the MesloLGS
  Nerd Font and the Catppuccin Macchiato colors.
- [Zsh](https://www.zsh.org/) is the shell. There is no plugin manager: the
  first time Zsh starts, `.zshrc` downloads each plugin into
  `~/.local/share/zsh/plugins`. Run `zsh-plugins-update` to update them. The
  plugins are:
  - [Powerlevel10k](https://github.com/romkatv/powerlevel10k), the prompt.
    Its settings are in `common/p10k/.p10k.zsh`.
  - [fzf-tab](https://github.com/Aloxaf/fzf-tab), which shows Tab completions
    in fzf.
  - [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions),
    which suggests a command from your history as you type. Press Right or End
    to accept it.
  - [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting),
    which colors the command as you type.
  - [zsh-history-substring-search](https://github.com/zsh-users/zsh-history-substring-search),
    which makes Up and Down search your history for what you've typed so far.
  - [zsh-completions](https://github.com/zsh-users/zsh-completions), which
    adds completions for more commands, such as `mvn`, `node` and `openssl`.
- [fzf](https://github.com/junegunn/fzf) is a fuzzy finder. Press `Ctrl+R` to
  search history, `Ctrl+T` to pick a file and `Alt+C` to change directory.
- [zoxide](https://github.com/ajeetdsouza/zoxide) remembers the directories
  you visit. Type `z` and part of a name to jump to one, or `zi` to pick from a
  list.
- [fnm](https://github.com/Schniz/fnm) switches Node.js versions when you
  change into a project that pins one.
- [SDKMAN](https://sdkman.io/) switches Java versions on macOS. When you change
  into a project with a `.sdkmanrc` file, it switches to that project's Java.
  The health check is turned off, because it makes a network request on every
  `sdk` call, which slows down each new shell and every `cd`.
- [direnv](https://direnv.net/) loads environment variables from a project's
  `.envrc` file. It's only enabled if it's installed.
- [tmux](https://github.com/tmux/tmux) splits one terminal into many. The
  prefix key is `Ctrl+A`, and copy mode uses Vim keys.
  [tpm](https://github.com/tmux-plugins/tpm) manages its plugins, and
  [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) restores
  your sessions after a reboot.

## Neovim

The [Neovim](https://neovim.io/) config started from
[kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim). Each plugin has
its own file in `lua/plugins/`, and `lazy-lock.json` pins every plugin to an
exact version.

### Core

- [lazy.nvim](https://github.com/folke/lazy.nvim) installs and loads the
  plugins.
- [catppuccin/nvim](https://github.com/catppuccin/nvim) is the color scheme,
  in its Macchiato flavor.
- [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) is the status
  line.
- [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons) adds file
  icons to the pickers and the status line.
- [guess-indent.nvim](https://github.com/NMAC427/guess-indent.nvim) detects
  each file's indentation.

### Finding files

- [fzf-lua](https://github.com/ibhagwan/fzf-lua) searches files, text,
  buffers, help, diagnostics and symbols. Its shortcuts start with `;`, for
  example `;f` for files and `;r` to search text.
- [oil.nvim](https://github.com/stevearc/oil.nvim) lets you edit a directory
  as if it were a text file. Press `sf` to open it.

### Language support

- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) provides the
  settings for each language server.
- [mason.nvim](https://github.com/mason-org/mason.nvim),
  [mason-lspconfig.nvim](https://github.com/mason-org/mason-lspconfig.nvim)
  and
  [mason-tool-installer.nvim](https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim)
  install the language servers, linters and formatters.
- [fidget.nvim](https://github.com/j-hui/fidget.nvim) shows language server
  progress in the corner.
- [lazydev.nvim](https://github.com/folke/lazydev.nvim) teaches the Lua
  language server about the Neovim API, for editing this config.
- [blink.cmp](https://github.com/Saghen/blink.cmp) shows completions, and
  [LuaSnip](https://github.com/L3MON4D3/LuaSnip) expands snippets.
- [nvim-java](https://github.com/nvim-java/nvim-java) sets up Java support.
  It downloads the Java language server and the JDK it runs on. A Gradle
  script fixes the source folders of Grails projects, so that Java code can
  see compiled Groovy classes.
- [grails.nvim](https://github.com/vdassios/grails.nvim) adds Grails support:
  GSP highlighting, `:GrailsAlternate` to jump between related files, and
  [grails-language-server](https://github.com/vdassios/grails-language-server)
  for Groovy and GSP. Run `:GrailsInstallServer` to download the server. If
  `~/Projects/grails.nvim` exists, the plugin loads from there instead of
  GitHub.

The configured language servers are `lua_ls`, `ts_ls`, `vue_ls`, `cssls`,
`tailwindcss`, `html` (also used in GSP files), `astro`, `svelte`, `pyright`,
`yamlls`, `tombi`, `jdtls`, `grails_ls` and `grails`.

### Formatting and linting

- [conform.nvim](https://github.com/stevearc/conform.nvim) formats files when
  you save, except C, C++, Vue and Java files. It uses `stylua`, `isort`,
  `black`, `prettierd`, `prettier`, `dockerfmt`, `rustywind`, `tombi`,
  `markdownlint` and `beautysh`.
- [nvim-lint](https://github.com/mfussenegger/nvim-lint) runs `eslint_d`,
  `markdownlint`, `jsonlint`, `hadolint` and `vale`.

### Editing

- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
  provides syntax highlighting and indentation.
- [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) marks changed
  lines and lets you stage, reset, preview and blame them.
- [nvim-autopairs](https://github.com/windwp/nvim-autopairs) closes brackets
  and quotes for you.
- [render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim)
  formats headings, code blocks, tables and checkboxes in Markdown files.

## Other tools

- [yazi](https://github.com/sxyazi/yazi) is the file manager. Press `Super+F`
  to open it, or type `y` in a shell to open it and stay in the directory you
  end up in. It also opens folders from other apps and replaces the system file
  picker. Its theme is pinned in `package.toml`. Run `ya pkg install` to
  restore it.
- [btop](https://github.com/aristocratos/btop) shows CPU, memory and process
  usage. Press `Super+T` to open it.
- [lazydocker](https://github.com/jesseduffield/lazydocker) manages Docker
  containers. Press `Super+D` to open it.
- [Obsidian](https://obsidian.md/) is for notes. Press `Super+O` to open it.
- [Signal](https://signal.org/) is for messages. Press `Super+G` to open it.
- [pamixer](https://github.com/cdemoulins/pamixer),
  [gum](https://github.com/charmbracelet/gum) and [jq](https://jqlang.org/) are
  used by Waybar and the helper scripts.

## Scripts and services

- `scripts/` holds the helper scripts that Hyprland, Waybar and systemd run:
  launchers, the battery monitor, the screen lock and a time zone picker. They
  need to be installed by hand. See [`scripts/README.md`](scripts/README.md).
- `scripts/first-run/` holds scripts that you run once on a new machine. On
  Arch, they set up a signed boot chain in which the TPM chip unlocks the disk,
  so the login screen is the only password prompt. On macOS, `macos.sh`
  installs the apps and changes system settings. See
  [`scripts/first-run/README.md`](scripts/first-run/README.md).
- `linux/systemd/` holds two user services: a timer that warns you when the
  battery is low, and the Elephant service for Walker.
- `linux/applications/` makes yazi the default app for folders.
- `linux/portals/` sends "Open file" and "Save as" dialogs to yazi.
- `common/themes/` holds a qBittorrent theme.
