{
  config,
  sopsAgeKeyFile ? "${config.xdg.configHome}/sops/age/keys.txt",
  ...
}:

{
  imports = [
    ../modules/home/display.nix
    ../modules/home/base.nix
    ../modules/home/dev.nix
    ../modules/home/personal-apps.nix
    ../modules/home/gaming-tools.nix
    ../modules/home/wezterm/wezterm.nix
    ../modules/home/neovim/neovim.nix
    ../modules/home/git/git.nix
    ../modules/home/containers/containers.nix
    ../modules/home/mise/mise.nix
    ../modules/home/ssh/ssh.nix
    ../modules/home/zsh/zsh.nix
    ../modules/home/starship/starship.nix
    ../modules/home/plasma/plasma.nix
    ../modules/home/feliciterra-fileshares.nix
    ../modules/home/1password/1password.nix
    ../modules/home/duplicati/duplicati.nix
  ];

  programs.firefox.enable = true;

  programs.claude-code = {
    enable = true;
  };

  # Configure SMB mounts
  services.smb-mounts = {
    enable = true;
    mounts.feliciterra = {
      share = "//10.0.0.105/feliciterra-storage";
      mountPoint = "mnt/feliciterra";
    };
  };

  services.duplicati.enable = true;

  # Configure sops
  sops = {
    defaultSopsFile = ../secrets/smb.yaml;
    age.keyFile = sopsAgeKeyFile;
  };
}
