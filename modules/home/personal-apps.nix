{ pkgs, ... }:

{
  home.packages = with pkgs; [
    discord
    proton-vpn
  ] ++ lib.optionals (pkgs.stdenv.isLinux) [
    libreoffice
    # This causes Alfred to hang on macOS, so only install on Linux due to a
    # bug in macOS 26 (Tahoe) that causes mds to index the entire app bundle. Or
    # something like that. Either way this specific app causes Alfred to choke.
    element-desktop
  ];
}
