# macOS-Specific Configuration

if [[ "$_macos" == "true" ]]; then
  # Fix pyenv to use openssl from homebrew
  alias pyenv='CFLAGS="-I$(brew --prefix openssl)/include" LDFLAGS="-L$(brew --prefix openssl)/lib" pyenv'

  # ITerm2 shell integration
  test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

  # Add sbin to PATH
  export PATH="$PATH:/usr/local/sbin"

  # Add Android Studio platform-tools to PATH
  if [ -d "$HOME/Library/Android/sdk/platform-tools" ]; then
    export PATH="$PATH:$HOME/Library/Android/sdk/platform-tools"
  fi

  # File watchers need a higher limit or they fail on large projects
  ulimit -n 10240
fi
