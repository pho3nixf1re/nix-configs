{ config, lib, ... }:

let
  cfg = config.local.wiredVrRouter;
in
{
  imports = [
    ./network.nix
  ];

  options.local.wiredVrRouter = {
    enable = lib.mkEnableOption "USB-attached wired VR router uplink";

    lanInterface = lib.mkOption {
      type = lib.types.str;
      description = "USB router-facing interface (for example enp49s0f3u1c2).";
    };

    wanInterface = lib.mkOption {
      type = lib.types.str;
      description = "Upstream interface used for NAT masquerade (for example enp39s0).";
    };

    lanConnectionName = lib.mkOption {
      type = lib.types.str;
      default = "Wired connection 2";
      description = "NetworkManager connection profile bound to the USB router interface.";
    };

    lanRouteMetric = lib.mkOption {
      type = lib.types.int;
      default = 700;
      description = "Route metric applied to the USB router profile so it does not win default route selection.";
    };

    lanAutoconnectPriority = lib.mkOption {
      type = lib.types.int;
      default = 0;
      description = "NetworkManager autoconnect priority for the USB router profile.";
    };

    routerProvidesDhcp = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether the attached router provides DHCP/default gateway on the LAN link.";
    };

    lanAddress = lib.mkOption {
      type = lib.types.str;
      default = "10.0.110.1";
      description = "Static host IP for host-managed mode (routerProvidesDhcp = false).";
    };

    subnet = lib.mkOption {
      type = lib.types.str;
      default = "10.0.110.0/24";
      description = "Subnet CIDR for host-managed mode (routerProvidesDhcp = false).";
    };

    dhcpRange = lib.mkOption {
      type = lib.types.str;
      default = "10.0.110.10,10.0.110.50,24h";
      description = "dnsmasq DHCP range string for host-managed mode.";
    };
  };
}
