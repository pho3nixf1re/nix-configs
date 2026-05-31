{ pkgs, ... }:

{
  services.wivrn = {
    enable = true;
    autoStart = false;
    openFirewall = true;
    steam.importOXRRuntimes = true;

    # Configuration to be set once I have it figured out. See: https://mynixos.com/nixpkgs/option/services.wivrn.config.json
    # config = {
    #   enable = false;
    #   config.json = {};
    # };
  };

  environment.systemPackages = with pkgs; [
    # Provides adb for working with Meta Quest 3 and 3s.
    android-tools
    sidequest

    # OpenVR→OpenXR translation: lets SteamVR-only titles run via WiVRn/Monado
    # xrizer is the modern replacement for opencomposite (fallback)
    xrizer # from nixpkgs-xr overlay
    opencomposite # from nixpkgs-xr overlay

    # WayVR: Virtual Desktop-style desktop overlay inside VR
    # Run with: steam-run wayvr (required on NixOS due to Steam FHS sandbox)
    wayvr # from nixpkgs-xr overlay

    # Proton GE builds with OpenXR runtime support, for running SteamVR-only
    # titles via WiVRn/Monado. Includes low-latency patches relevant to VR
    # streaming.
    proton-ge-rtsp-bin
  ];
}
