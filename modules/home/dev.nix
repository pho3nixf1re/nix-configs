{ lib, pkgs, ... }:

{
  programs.vscode.enable = true;

  systemd.user.sessionVariables = {
    # For native wayland support for VS Code and any other Electron apps.
    NIXOS_OZONE_WL = "1";
    # For Firefox Wayland support.
    MOZ_ENABLE_WAYLAND = "1";
  };

  programs.neovim = {
    enable = true;
    defaultEditor = false;
    viAlias = true;
    vimAlias = true;
  };

  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    # Conflicts with ssh-agent and git signing.
    enableSshSupport = false;
    enableBashIntegration = true;
    pinentryPackage = lib.mkIf pkgs.stdenv.isLinux pkgs.pinentry-qt;
  };

  home.packages = with pkgs; [
    nodejs
    python3
    nixfmt
    nil
    gh
  ];
}
