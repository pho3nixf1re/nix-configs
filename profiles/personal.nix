{ config, ... }:

{
  imports = [
    ../modules/home/base.nix
    ../modules/home/dev.nix
    ../modules/home/personal-apps.nix
    ../modules/home/gaming-tools.nix
    ../modules/home/neovim/neovim.nix
    ../modules/home/mise/mise.nix
    ../modules/home/ssh/ssh.nix
    ../modules/home/zsh/zsh.nix
    ../modules/home/starship/starship.nix
    ../modules/home/plasma/plasma.nix
    ../modules/home/feliciterra-fileshares.nix
    ../modules/home/1password/1password.nix
    ../modules/home/duplicati/duplicati.nix
  ];

  home.username = "pho3nixf1re";
  home.homeDirectory = "/home/pho3nixf1re";
  home.stateVersion = "26.05";

  programs.firefox.enable = true;

  programs.obsidian.enable = true;

  # Configure SMB mounts
  services.smb-mounts = {
    enable = true;
    mounts.feliciterra = {
      share = "//feliciterra-nas/feliciterra-storage";
      mountPoint = "mnt/feliciterra";
    };
  };

  services.duplicati.enable = true;

  # Configure sops
  sops = {
    defaultSopsFile = ../secrets/smb.yaml;
    age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
  };
}
