# remember that this is a symlink to ~/.zshrc
# enable built-in profiling
# see also end of file
#zmodload zsh/zprof

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

### ZSH HOME
export ZSH=$HOME/.zsh

### ---- history config --------------------------------
export HISTFILE=$ZSH/.zsh_history

# How many commands zsh will load to memory.
export HISTSIZE=10000

# How many commands history will save on file.
export SAVEHIST=10000

# History won't save duplicates.
setopt HIST_IGNORE_ALL_DUPS

# History won't show duplicates on search.
setopt HIST_FIND_NO_DUPS

# bat theme
#export BAT_THEME="ansi"

# aliases
alias fd="fdfind"
alias nnn="nnn -e"
alias luamake=/home/vdassios/.config/nvim/lua-language-server/3rd/luamake/luamake
alias ls="ls --color=auto"
alias vpnup="sudo wg-quick up wg0"
alias vpndown="sudo wg-quick down wg0"


# fnm
export PATH="/home/vdassios/.local/share/fnm:$PATH"
eval "`fnm env`"
eval "$(fnm env --use-on-cd)"

# NNN
export NNN_PLUG="p:preview-tui;f:fzcd;j:autojump;d:dragdrop"
export NNN_FIFO="/tmp/nnn.fifo"
# we give a custom title to spawned terminal
# so that we can unfocus it in i3 config
export NNN_TERMINAL="alacritty --title preview-tui"
export NNN_BMS="k:$HOME/Projects/kambi-recommender-widget;o:$HOME/Projects/betconstruct-recommender-widget;n:$HOME/.config/nvim/;i:$HOME/.config/i3"

# asdf package manager
. $HOME/.asdf/asdf.sh
  # append completions to fpath
fpath=(/home/vdassios/.asdf/completions $fpath)
# makes shell slow, need to debug
# initialize completions with ZSH's compinit
# autoload -Uz compinit && compinit


# autojump
. /usr/share/autojump/autojump.sh

# ---- PLUGINS & THEMES
source $ZSH/themes/spaceship-prompt/spaceship.zsh-theme
source $ZSH/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source $ZSH/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
fpath=($ZSH/plugins/zsh-completions/src $fpath)

# ---- Spaceship Config ----
SPACESHIP_PROMPT_ORDER=(
  user          # Username section
  dir           # Current directory section
  host          # Hostname section
  git           # Git section (git_branch + git_status)
  node
  exec_time     # Execution time
  line_sep      # Line break
  jobs          # Background jobs indicator
  exit_code     # Exit code section
  char          # Prompt character
)
SPACESHIP_USER_SHOW=always
SPACESHIP_USER_COLOR=147
SPACESHIP_PROMPT_ADD_NEWLINE=false
SPACESHIP_CHAR_SYMBOL="❯"
SPACESHIP_CHAR_SUFFIX=" "

# enable built-in profiling
#zprof
