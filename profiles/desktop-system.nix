{ pkgsSystem, ... }:

{
  # Desktop system profile
  # For full desktop systems (not SteamOS), running Wayland.

  custom.display.server = "wayland";

  # discover writes the session config the system channel's Plasma reads, so
  # it has to come from that same channel.
  home.packages = with pkgsSystem.kdePackages; [
    discover
  ];

  imports = [
    ../modules/home/gaming-tools.nix
    ../modules/home/book-management.nix
  ];
}
