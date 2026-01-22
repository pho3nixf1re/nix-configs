# PATH Configuration

# Add user bin directories to PATH
if [ -d "$HOME/bin" ]; then
  export PATH="$PATH:$HOME/bin"
fi

if [ -d "$HOME/.local/bin" ]; then
  export PATH="$PATH:$HOME/.local/bin"
fi
