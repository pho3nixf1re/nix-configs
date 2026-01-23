{ pkgs, ... }:

{
  programs.vscode.enable = true;
  # For native wayland support for VS Code and any other Electron apps.
  home.sessionVariables.NIXOS_OZONE_WL = "1";

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
  };
  services.gpg-agent.pinentry.package = pkgs.pinentry-qt;

  home.packages = with pkgs; [
    nodejs
    python3
    nixfmt
    nil
    gh
  ];
}
