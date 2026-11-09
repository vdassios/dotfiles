# macOS-only environment, sourced at the top of common/zsh/.zshrc before
# plugins load: `fzf --zsh` and the tools below need Homebrew on PATH.
[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
