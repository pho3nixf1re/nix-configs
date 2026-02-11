{ pkgs, ... }:

{
  programs.element-desktop.enable = true;

  home.packages =
    with pkgs;
    [
      libreoffice
      discord
      protonvpn-gui
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [
      bottles
    ];
}
