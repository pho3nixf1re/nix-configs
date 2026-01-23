{
  config,
  pkgs,
  lib,
  ...
}:

let
  onepasswordDir = "${config.home.homeDirectory}/.1password";
  agentSock = "${onepasswordDir}/agent.sock";
  macosAgentSock = "${config.home.homeDirectory}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
in
{
  xdgConfig.file = {
    "1Password/ssh".source = ./agent.toml;
  };

  # Create .1password directory if it does not exist.
  home.file.".1password/.keep".text = "";

  # Create symlink on macOS from macOS-specific socket to common location
  home.file.".1password/agent.sock" = lib.mkIf pkgs.stdenv.isDarwin {
    source = config.lib.file.mkOutOfStoreSymlink macosAgentSock;
  };

  home.sessionVariables = {
    SSH_AUTH_SOCK = agentSock;
  };
}
