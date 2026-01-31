{ pkgs, ... }:

{
  home.packages = with pkgs; [
    libreoffice
    discord
    protonvpn-gui
  ];
}
