#!/usr/bin/env zsh

function port-killer() {
  if [[ $1 == "-h" || $1 == "--help" || -z $1 ]]; then
    echo "Usage: port-killer PORT"
    echo "Kills the process running on the specified PORT."
    return
  fi

  local PORT=$1
  kill -9 $(lsof -t -i tcp:$PORT)
}
