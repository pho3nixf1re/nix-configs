{ pkgs, ... }:

{
  # Might put this in a server on the NAS.
  home.packages = with pkgs; [
    libation
    # See: https://github.com/NixOS/nixpkgs/issues/493843
    (calibre.overrideAttrs (oldAttrs: {
      installPhase = ''
        export QMAKE="${qt6.qtbase}/bin/qmake"
      ''
      + oldAttrs.installPhase;
    }))
  ];

  # See: https://github.com/Leseratte10/acsm-calibre-plugin/issues/68#issuecomment-2162686156
  home.sessionVariables = {
    ACSM_LIBCRYPTO = "${pkgs.openssl.out}/lib/libcrypto.so";
    ACSM_LIBSSL = "${pkgs.openssl.out}/lib/libssl.so";
  };
}
