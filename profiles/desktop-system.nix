{ pkgs, ... }:

{
  # Desktop system profile
  # For full desktop systems (not SteamOS)

  home.packages = with pkgs; [
    kdePackages.discover
    wl-clipboard
  ];

  systemd.user.sessionVariables = {
    # For native wayland support for VS Code and any other Electron apps.
    NIXOS_OZONE_WL = "1";
    # For Firefox Wayland support.
    MOZ_ENABLE_WAYLAND = "1";
  };

  imports = [
    ../modules/home/gaming-tools.nix
    ../modules/home/book-management.nix
  ];
}
