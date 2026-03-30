{
  config,
  lib,
  ...
}:

let
  cfg = config.local.wirelessAp;
  devUnit = "sys-subsystem-net-devices-${cfg.wlanInterface}.device";
  rfkillSvc = "wireless-ap-rfkill-unblock-${cfg.wlanInterface}.service";
  powerSaveSvc = "wireless-ap-powersave-off-${cfg.wlanInterface}.service";
  ht40Capability =
    if
      lib.elem cfg.channel [
        36
        40
        44
        149
        153
      ]
    then
      "HT40+"
    else if
      lib.elem cfg.channel [
        48
        157
        161
      ]
    then
      "HT40-"
    else
      null;
  vhtCenterFreqSeg0Idx =
    if
      lib.elem cfg.channel [
        36
        40
        44
        48
      ]
    then
      42
    else if
      lib.elem cfg.channel [
        149
        153
        157
        161
      ]
    then
      155
    else
      null;
in
lib.mkIf cfg.enable {
  services.hostapd = {
    enable = true;
    radios.${cfg.wlanInterface} = {
      # 802.11ax (WiFi 6) in 5 GHz.
      wifi4.enable = true;
      wifi4.capabilities = lib.mkIf (ht40Capability != null) [
        ht40Capability
        "SHORT-GI-20"
        "SHORT-GI-40"
      ];
      wifi5.enable = true;
      wifi5.operatingChannelWidth = "80";
      # mt7921u AP mode is more stable with WiFi 5 than WiFi 6 on some channels.
      wifi6.enable = false;
      band = "5g";
      channel = cfg.channel;
      countryCode = cfg.countryCode;
      settings = lib.mkIf (vhtCenterFreqSeg0Idx != null) {
        vht_oper_centr_freq_seg0_idx = vhtCenterFreqSeg0Idx;
      };
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
    requires = [
      rfkillSvc
      powerSaveSvc
    ];
    after = [
      devUnit
      rfkillSvc
      powerSaveSvc
    ];
    bindsTo = [ devUnit ];
    unitConfig = {
      StartLimitIntervalSec = "2min";
      StartLimitBurst = 2;
    };
    serviceConfig.RestartSec = "10s";
    wantedBy = lib.mkForce [ ];
  };
}
