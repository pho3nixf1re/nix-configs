{ pkgs, ... }:

{
  # Desktop system profile
  # For full desktop systems (not SteamOS)

  home.packages = with pkgs; [
    kdePackages.discover
  ];

  imports = [
    ../modules/home/gaming-tools.nix
  ];
}
