{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    iw
    usbutils
    wirelesstools
    hostapd
    dnsmasq
  ];
}
