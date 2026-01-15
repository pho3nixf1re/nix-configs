{ pkgs, ... }:

{
  # Shared gaming tools useful on all platforms (including SteamOS)
  # Does NOT include Steam itself.

  home.packages = with pkgs; [
    # Game launchers and compatibility tools
    heroic

    # Proton/Wine management
    protonup-qt
  ];
}
