{ config, ... }:

{
  imports = [
    ../modules/home/base.nix
    ../modules/home/dev.nix
    ../modules/home/gaming-tools.nix
    ../modules/home/ssh/ssh.nix
    ../modules/home/zsh/zsh.nix
    ../modules/home/starship/starship.nix
    ../modules/home/plasma/plasma.nix
    ../modules/home/smb/smb.nix
  ];

  home.username = "pho3nixf1re";
  home.homeDirectory = "/home/pho3nixf1re";
  home.stateVersion = "26.05";

  programs.firefox.enable = true;

  # Configure SMB mounts
  services.smb-mounts = {
    enable = true;
    mounts.feliciterra = {
      share = "//feliciterra-nas/feliciterra-storage";
      mountPoint = "mnt/feliciterra";
    };
  };

  # Configure sops
  sops = {
    defaultSopsFile = ../secrets/smb.yaml;
    age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
  };
}
