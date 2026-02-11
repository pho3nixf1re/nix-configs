{ pkgs, ... }:

{
  programs.alvr = {
    enable = true;
    openFirewall = true;
  };

  services.wivrn = {
    enable = true;
    autoStart = false;
    openFirewall = true;
    steam.importOXRRuntimes = true;

    # Configuration to be set once I have it figured out. See: https://mynixos.com/nixpkgs/option/services.wivrn.config.json
    # config = {
    #   enable = false;
    #   config.json = {};
    # };
  };

  environment.systemPackages = with pkgs; [
    # Provides adb for working with Meta Quest 3 and 3s.
    android-tools

    sidequest
  ];
}
