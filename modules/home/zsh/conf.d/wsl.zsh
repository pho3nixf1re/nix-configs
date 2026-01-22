# WSL-Specific Configuration

if [[ "$_wsl" == "true" ]]; then
  # Use Windows SSH client for 1password ssh-agent
  alias ssh='ssh.exe'
  alias ssh-add='ssh-add.exe'
fi
