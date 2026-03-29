{ config, lib, ... }:

let
  cfg = config.local.wirelessAp;
in
{
  imports = [
    ./network.nix
    ./hostapd.nix
    ./dnsmasq.nix
    ./secrets.nix
  ];

  options.local.wirelessAp = {
    enable = lib.mkEnableOption "USB WiFi AP for VR headset streaming";

    wlanInterface = lib.mkOption {
      type = lib.types.str;
      description = "MAC-based wlan interface name of the USB WiFi adapter (e.g. wlxaabbccddee).";
    };

    wanInterface = lib.mkOption {
      type = lib.types.str;
      description = "Upstream interface for NAT masquerade (e.g. enp39s0).";
    };

    apAddress = lib.mkOption {
      type = lib.types.str;
      default = "10.0.100.1";
      description = "Static IP address assigned to the AP interface.";
    };

    subnet = lib.mkOption {
      type = lib.types.str;
      default = "10.0.100.0/24";
      description = "Subnet CIDR for the AP network.";
    };

    dhcpRange = lib.mkOption {
      type = lib.types.str;
      default = "10.0.100.10,10.0.100.50,24h";
      description = "dnsmasq DHCP range string.";
    };

    ssid = lib.mkOption {
      type = lib.types.str;
      description = "WiFi SSID to broadcast.";
    };

    channel = lib.mkOption {
      type = lib.types.int;
      default = 36;
      description = "WiFi channel (default 36, U-NII-1, no DFS wait required).";
    };

    countryCode = lib.mkOption {
      type = lib.types.str;
      default = "US";
      description = "ISO 3166-1 alpha-2 country code for regulatory compliance.";
    };
  };
}
