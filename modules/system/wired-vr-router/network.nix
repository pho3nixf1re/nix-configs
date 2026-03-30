{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.local.wiredVrRouter;
  devUnit = "sys-subsystem-net-devices-${cfg.lanInterface}.device";
  ipSvc = "wired-vr-router-ip-${cfg.lanInterface}.service";
in
lib.mkIf cfg.enable {
  # Keep internet routing pinned to the primary WAN and avoid route races
  # when the USB router link is up.
  networking.networkmanager.ensureProfiles.profiles.${cfg.lanConnectionName} = {
    connection = {
      autoconnect-priority = toString cfg.lanAutoconnectPriority;
      id = cfg.lanConnectionName;
      type = "ethernet";
      interface-name = cfg.lanInterface;
    };
    ethernet = { };
    ipv4 = {
      method = "auto";
      never-default = true;
      route-metric = toString cfg.lanRouteMetric;
    };
    ipv6 = {
      method = "ignore";
    };
    proxy = { };
  };

  networking.nat = {
    enable = true;
    internalInterfaces = [ cfg.lanInterface ];
    externalInterface = cfg.wanInterface;
  };

  networking.firewall.interfaces.${cfg.lanInterface} = {
    allowedUDPPorts = lib.mkIf (!cfg.routerProvidesDhcp) [
      53
      67
    ];
  };

  # Host-managed mode (optional): assign a static IP to the LAN interface and
  # run dnsmasq for DHCP on that link.
  systemd.services.${ipSvc} = lib.mkIf (!cfg.routerProvidesDhcp) {
    description = "Assign static IP to wired VR interface ${cfg.lanInterface}";
    after = [ devUnit ];
    bindsTo = [ devUnit ];
    before = [ "dnsmasq.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.iproute2}/bin/ip addr add ${cfg.lanAddress}/24 dev ${cfg.lanInterface}";
      ExecStop = "${pkgs.iproute2}/bin/ip addr del ${cfg.lanAddress}/24 dev ${cfg.lanInterface}";
    };
  };

  services.dnsmasq = lib.mkIf (!cfg.routerProvidesDhcp) {
    enable = true;
    resolveLocalQueries = false;
    settings = {
      bind-interfaces = true;
      interface = cfg.lanInterface;
      dhcp-range = cfg.dhcpRange;
      server = [
        "10.0.0.1"
        "1.1.1.1"
        "8.8.8.8"
      ];
      log-dhcp = true;
    };
  };

  systemd.services.dnsmasq = lib.mkIf (!cfg.routerProvidesDhcp) {
    after = [
      devUnit
      ipSvc
    ];
    bindsTo = [ devUnit ];
  };

  services.udev.extraRules = lib.mkIf (!cfg.routerProvidesDhcp) ''
    ACTION=="add", SUBSYSTEM=="net", NAME=="${cfg.lanInterface}", \
      TAG+="systemd", \
      ENV{SYSTEMD_WANTS}+="${ipSvc} dnsmasq.service"
  '';
}
