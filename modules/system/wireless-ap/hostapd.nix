{ config, lib, ... }:

let
  cfg = config.local.wirelessAp;
in
lib.mkIf cfg.enable {
  services.hostapd = {
    enable = true;
    radios.${cfg.wlanInterface} = {
      # 802.11ax (WiFi 6) in 5 GHz.
      wifi4.enable = true;
      wifi5.enable = true;
      wifi6.enable = true;
      band = "5g";
      channel = cfg.channel;
      countryCode = cfg.countryCode;
      networks.${cfg.wlanInterface} = {
        ssid = cfg.ssid;
        authentication = {
          mode = "wpa3-sae";
          # Path to plaintext passphrase file decrypted by sops at runtime.
          saePasswordsFile = config.sops.secrets.wifiPassphrase.path;
        };
      };
    };
  };

  # The NixOS hostapd module enables networking.wireless (for firmware loading),
  # which with interfaces = [] means "all interfaces" and triggers a conflict
  # warning with hostapd. Force it off — firmware is covered by
  # hardware.enableRedistributableFirmware and NM handles client WiFi.
  networking.wireless.enable = lib.mkForce false;

  # Hotplug: started by udev rule in network.nix when the adapter appears.
  # Removed from multi-user.target to avoid 90s boot timeout when adapter is absent.
  systemd.services.hostapd = {
    after = [ "sys-subsystem-net-devices-${cfg.wlanInterface}.device" ];
    bindsTo = [ "sys-subsystem-net-devices-${cfg.wlanInterface}.device" ];
    wantedBy = lib.mkForce [ ];
  };
}
