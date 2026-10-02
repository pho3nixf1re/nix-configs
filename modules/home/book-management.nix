{ pkgsLatest, ... }:

{
  home.packages = with pkgsLatest; [
    libation
    calibre
  ];

  # See: https://github.com/Leseratte10/acsm-calibre-plugin/issues/68#issuecomment-2162686156
  home.sessionVariables = {
    ACSM_LIBCRYPTO = "${pkgsLatest.openssl.out}/lib/libcrypto.so";
    ACSM_LIBSSL = "${pkgsLatest.openssl.out}/lib/libssl.so";
  };
}
