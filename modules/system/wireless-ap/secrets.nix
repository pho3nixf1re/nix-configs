{ config, lib, ... }:

let
  cfg = config.local.wirelessAp;
in
lib.mkIf cfg.enable {
  # To create/edit the secret:
  #   sops secrets/wifi.yaml
  # with key:
  #   wifiPassphrase: "your-passphrase-here"
  sops.secrets.wifiPassphrase = {
    sopsFile = ../../../secrets/wifi.yaml;
  };
}
