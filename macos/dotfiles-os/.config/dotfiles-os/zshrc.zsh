# macOS-only zsh settings, sourced at the end of common/zsh/.zshrc.

# Java
export JAVA_HOME="$HOME/.local/jdks/jdk-11.0.31+11/Contents/Home"
export PATH=$JAVA_HOME/bin:$PATH

# THIS MUST BE AT THE END FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
