{ config, lib, pkgs, ... }:

let
  cfg = config.local.wirelessAp;
  ipSvc = "wireless-ap-ip-${cfg.wlanInterface}.service";
  devUnit = "sys-subsystem-net-devices-${cfg.wlanInterface}.device";
in
lib.mkIf cfg.enable {
  # Assign a static IP when the USB adapter appears.
  # Not added to multi-user.target — the udev rule below triggers it on hotplug.
  # BindsTo ensures the service stops (and IP is released) when the adapter is unplugged.
  systemd.services."wireless-ap-ip-${cfg.wlanInterface}" = {
    description = "Assign static IP to wireless AP interface ${cfg.wlanInterface}";
    after = [ devUnit ];
    bindsTo = [ devUnit ];
    # Must complete before dnsmasq binds to the interface address.
    before = [ "dnsmasq.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.iproute2}/bin/ip addr add ${cfg.apAddress}/24 dev ${cfg.wlanInterface}";
      ExecStop = "${pkgs.iproute2}/bin/ip addr del ${cfg.apAddress}/24 dev ${cfg.wlanInterface}";
    };
  };

  # Trigger all AP services via udev when the adapter appears, rather than
  # pulling them into multi-user.target. This avoids a 90-second boot timeout
  # when the adapter is absent.
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="net", NAME=="${cfg.wlanInterface}", \
      TAG+="systemd", \
      ENV{SYSTEMD_WANTS}+="${ipSvc} hostapd.service dnsmasq.service"
  '';

  # NAT from wlan → wan so clients can reach the internet.
  networking.nat = {
    enable = true;
    internalInterfaces = [ cfg.wlanInterface ];
    externalInterface = cfg.wanInterface;
  };

  # Keep NetworkManager away from the AP interface so it doesn't fight hostapd.
  networking.networkmanager.unmanaged = [ cfg.wlanInterface ];

  # Allow DHCP, DNS, and hostapd traffic from clients on the AP subnet.
  networking.firewall.interfaces.${cfg.wlanInterface} = {
    allowedUDPPorts = [
      53 # DNS
      67 # DHCP
    ];
  };
}
