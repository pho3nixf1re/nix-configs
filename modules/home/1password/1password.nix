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
  xdg.configFile = {
    "1Password/ssh".source = ./agent.toml;
  };

  # Create .1password directory if it does not exist.
  home.file.".1password/.keep".text = "";

  # Create symlink on macOS from MacOS-specific socket to common location.
  home.activation.link1PasswordSocket = lib.mkIf pkgs.stdenv.isDarwin (
    lib.hm.dag.entryAfter ["writeBoundary"] ''
      $DRY_RUN_CMD rm -f ${agentSock}
      $DRY_RUN_CMD ln -sf ${lib.escapeShellArg macosAgentSock} ${agentSock}
    ''
  );

  home.sessionVariables = {
    SSH_AUTH_SOCK = agentSock;
  };

  # This fixes on linux where VS Code cannot find the SSH agent socket.
  systemd.user.sessionVariables = {
    SSH_AUTH_SOCK = agentSock;
  };
}
