#!/bin/env zsh

local ONEPASSWORD_DIR="~/.1password"
local AGENT_SOCK="$ONEPASSWORD_DIR/agent.sock"
local MACOS_SOCK="~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
local errorMessage="1Password agent not running"

if [[ ! -d $ONEPASSWORD_DIR ]]; then
  mkdir -p $ONEPASSWORD_DIR
fi

# If on MacOS, symlink the agent socket to a common location
if [[ ! -S $AGENT_SOCK && $_macos = "true" && -S $MACOS_SOCK ]]; then
  ln -s $MACOS_SOCK $AGENT_SOCK
elif [[ ! -S $AGENT_SOCK  && !$_macos = "true" ]]; then
  echo $errorMessage
fi

export SSH_AUTH_SOCK=$AGENT_SOCK
