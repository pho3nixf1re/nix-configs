{ config, lib, ... }:

let
  cfg = config.local.wirelessAp;
in
lib.mkIf cfg.enable {
  services.dnsmasq = {
    enable = true;
    settings = {
      # Only bind to the AP interface — avoids conflicts with NetworkManager's
      # internal dnsmasq instance which listens on other interfaces.
      bind-interfaces = true;
      interface = cfg.wlanInterface;

      # DHCP pool for AP clients.
      dhcp-range = cfg.dhcpRange;

      # Forward upstream DNS queries to the system resolver.
      server = [ "1.1.1.1" "8.8.8.8" ];

      # Suppress "query from non-local network" log noise.
      log-dhcp = true;
    };
  };

  # Hotplug: started by udev rule in network.nix when the adapter appears.
  # Removed from multi-user.target to avoid 90s boot timeout when adapter is absent.
  # Also waits for the IP assignment service so the interface address exists before
  # dnsmasq tries to bind to it.
  systemd.services.dnsmasq = {
    after = [
      "sys-subsystem-net-devices-${cfg.wlanInterface}.device"
      "wireless-ap-ip-${cfg.wlanInterface}.service"
    ];
    bindsTo = [ "sys-subsystem-net-devices-${cfg.wlanInterface}.device" ];
    wantedBy = lib.mkForce [ ];
  };
}
