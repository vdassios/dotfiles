# Zsh configuration shared by both machines. Plugins are plain git clones
# under ~/.local/share/zsh/plugins, made on first start; update them with
# `zsh-plugins-update`.

# OS-specific environment that must exist before anything below runs
# (e.g. Homebrew's PATH on macOS), from the dotfiles-os package.
[[ -r ~/.config/dotfiles-os/env.zsh ]] && source ~/.config/dotfiles-os/env.zsh

# Keep only the first copy of each PATH entry, so nested shells and the
# prepends below don't pile up duplicates.
typeset -U PATH path FPATH fpath

# ---- Plugins ----------------------------------------------------------------
ZPLUGINS=${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins
zplugins=(
  romkatv/powerlevel10k
  zsh-users/zsh-completions
  Aloxaf/fzf-tab
  zsh-users/zsh-autosuggestions
  zsh-users/zsh-syntax-highlighting
  zsh-users/zsh-history-substring-search
)
# Clone missing plugins before the instant prompt below, which must not be
# followed by console output.
() {
  local repo
  for repo in $zplugins; do
    [[ -d $ZPLUGINS/${repo:t} ]] ||
      git clone --quiet --depth=1 https://github.com/$repo $ZPLUGINS/${repo:t}
  done
}
function zsh-plugins-update() {
  local repo
  for repo in $zplugins; do
    print -P "%B${repo:t}%b"
    git -C $ZPLUGINS/${repo:t} pull --ff-only --quiet
  done
}

# Powerlevel10k instant prompt: draws the prompt immediately while the rest
# of this file loads. Anything that reads console input must go above it.
if [[ -r ${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh ]]; then
  source ${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh
fi

source $ZPLUGINS/powerlevel10k/powerlevel10k.zsh-theme
[[ -r ~/.p10k.zsh ]] && source ~/.p10k.zsh

# ---- Environment ------------------------------------------------------------
path=(~/.opencode/bin ~/.local/bin ~/bin $path)

export EDITOR=nvim
export GPG_TTY=$TTY
export PAGER=less
export LESS=-iRFXMx4  # case-insensitive search, colors, quit if one screen

# Colors for GNU ls and completion lists (LS_COLORS), BSD ls (LSCOLORS) and
# tree (TREE_COLORS, without underlines).
export LS_COLORS='fi=00:mi=00:mh=00:ln=01;36:or=01;31:di=01;34:ow=04;01;34:st=34:tw=04;34:pi=01;33:so=01;33:do=01;33:bd=01;33:cd=01;33:su=01;35:sg=01;35:ca=01;35:ex=01;32'
export LSCOLORS='ExGxDxDxCxDxDxFxFxexEx'
export TREE_COLORS=${LS_COLORS//04;}

# fzf catppuccin macchiato
export FZF_DEFAULT_OPTS=" \
--color=spinner:#F4DBD6,hl:#ED8796 \
--color=fg:#CAD3F5,header:#ED8796,info:#C6A0F6,pointer:#F4DBD6 \
--color=marker:#B7BDF8,fg+:#CAD3F5,prompt:#C6A0F6,hl+:#ED8796 \
--color=selected-bg:#494D64 \
--color=border:#6E738D,label:#CAD3F5"

# ---- Options ----------------------------------------------------------------
setopt auto_cd               # type a directory name to cd into it
setopt auto_pushd            # cd pushes onto the directory stack (cd -<TAB>)
setopt extended_glob
setopt glob_dots             # globs match dotfiles
setopt interactive_comments
setopt no_beep
setopt no_flow_control       # free Ctrl+S / Ctrl+Q
setopt always_to_end         # move to the end of a word after completing it

# History: the file and the effectively unlimited size z4h used.
HISTFILE=$HOME/.zsh_history
HISTSIZE=1000000000
SAVEHIST=1000000000
setopt extended_history      # the history file is already in this format
setopt share_history
setopt hist_ignore_dups
setopt hist_ignore_space     # a leading space keeps a command out of history
setopt hist_find_no_dups
setopt hist_save_no_dups
setopt hist_verify
setopt hist_fcntl_lock

# ---- Completion -------------------------------------------------------------
fpath=($ZPLUGINS/zsh-completions/src $fpath)
autoload -Uz compinit
mkdir -p ${XDG_CACHE_HOME:-$HOME/.cache}/zsh
compinit -d ${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'  # lower case matches upper
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu no                       # fzf-tab draws the menu
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path ${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache
zstyle ':fzf-tab:*' use-fzf-default-opts yes          # Catppuccin colors above

# fzf's Ctrl+R (history), Ctrl+T (files) and Alt+C (cd) widgets. Loaded
# before fzf-tab so that fzf-tab owns TAB.
source <(fzf --zsh)
source $ZPLUGINS/fzf-tab/fzf-tab.plugin.zsh

# ---- Key bindings -----------------------------------------------------------
# Emacs keymap. Without this, zsh picks the vi keymap because $EDITOR
# contains "vi".
bindkey -e

# Ctrl+Backspace deletes one path component, not the whole path.
WORDCHARS=${WORDCHARS//\/}

# Ctrl+Alt+Backspace deletes a whole shell argument.
autoload -Uz backward-kill-word-match
zle -N backward-kill-shell-word backward-kill-word-match
zstyle ':zle:backward-kill-shell-word' word-style shell

() {
  # Each key is listed with the sequences Alacritty and tmux send for it.
  local -A keys=(
    '^[[H'    beginning-of-line         # Home
    '^[OH'    beginning-of-line
    '^[[1~'   beginning-of-line
    '^[[F'    end-of-line               # End
    '^[OF'    end-of-line
    '^[[4~'   end-of-line
    '^[[3~'   delete-char               # Delete
    '^[[1;5C' forward-word              # Ctrl+Right
    '^[[1;5D' backward-word             # Ctrl+Left
    '^[[3;5~' kill-word                 # Ctrl+Delete
    '^H'      backward-kill-word        # Ctrl+Backspace
    '^[^H'    backward-kill-shell-word  # Ctrl+Alt+Backspace
    '^[^?'    backward-kill-shell-word
    '^_'      undo                      # Ctrl+/
    '^[[Z'    undo                      # Shift+Tab
    '^[/'     redo                      # Alt+/
  )
  local key
  for key in ${(k)keys}; do bindkey $key $keys[$key]; done
}

# ---- Terminal title: the running command, else the current directory -------
autoload -Uz add-zsh-hook
function _title_precmd()  { print -Pn '\e]0;%~\a' }
function _title_preexec() { print -rn -- $'\e]0;'${(V)1}$'\a' }
add-zsh-hook precmd  _title_precmd
add-zsh-hook preexec _title_preexec

# ---- Tools ------------------------------------------------------------------
# zoxide: `z` jumps to a frecent directory, `zi` picks one with fzf.
eval "$(zoxide init zsh)"

(( $+commands[direnv] )) && eval "$(direnv hook zsh)"

# fnm (installed to ~/.local/share/fnm, not on PATH by default)
FNM_PATH="$HOME/.local/share/fnm"
if [[ -d $FNM_PATH ]]; then
  path=($FNM_PATH $path)
  eval "$(fnm env --use-on-cd --shell zsh)"
fi

# yazi: `y` opens yazi and cds to the directory it was left in.
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

# ---- Functions and aliases --------------------------------------------------
autoload -Uz zmv

function md() { [[ $# == 1 ]] && mkdir -p -- "$1" && cd -- "$1" }
compdef _directories md

# GNU coreutils (has dircolors) takes --color; BSD ls takes -G.
if (( $+commands[dircolors] )); then
  alias ls='ls --color=auto -A'
  alias diff='diff --color=auto'
else
  alias ls='ls -G -A'
fi
alias grep='grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn}'
alias tree='tree -a -I .git'
alias mkexec='chmod +x'

# Machine-local overrides (not tracked).
[[ -r ~/.env.zsh ]] && source ~/.env.zsh

# ---- Plugins that wrap widgets: keep last, in this order --------------------
source $ZPLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh
source $ZPLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $ZPLUGINS/zsh-history-substring-search/zsh-history-substring-search.zsh
HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1
bindkey '^[[A' history-substring-search-up    # Up
bindkey '^[OA' history-substring-search-up
bindkey '^[[B' history-substring-search-down  # Down
bindkey '^[OB' history-substring-search-down

# OS-specific settings (JAVA_HOME, SDKMAN, ...) from the dotfiles-os package
# for this OS. Keep this last: SDKMAN's init must run at the end of the file.
[[ -r ~/.config/dotfiles-os/zshrc.zsh ]] && source ~/.config/dotfiles-os/zshrc.zsh
