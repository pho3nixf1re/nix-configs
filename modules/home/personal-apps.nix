{ pkgs, ... }:

{
  programs.element-desktop.enable = true;

  home.packages = with pkgs; [
    discord
    element-desktop
    proton-vpn
  ] ++ lib.optionals (pkgs.stdenv.isLinux) [
    libreoffice
  ];
}
