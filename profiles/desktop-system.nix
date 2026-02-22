{ pkgs, ... }:

{
  # Desktop system profile
  # For full desktop systems (not SteamOS), running Wayland.

  custom.display.server = "wayland";

  home.packages = with pkgs; [
    kdePackages.discover
  ];

  imports = [
    ../modules/home/gaming-tools.nix
    ../modules/home/book-management.nix
  ];
}
