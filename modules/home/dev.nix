{ pkgs, ... }:

{
  programs.vscode.enable = true;

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
  services.gpg-agent.pinentryPackage = pkgs.pinentry-qt;

  home.packages = with pkgs; [
    nodejs
    python3
    nixfmt
    nil
    gh
  ];
}
