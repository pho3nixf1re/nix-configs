{ config, pkgs, ... }:

{
  # NOTE: This module uses the nixpkgs-xr overlay for VR packages.
  #
  # The nixpkgs-xr overlay is configured in flake.nix and provides:
  # - xrizer: Modern OpenVR→OpenXR translation layer
  # - opencomposite: Fallback OpenVR→OpenXR translator
  # - wayvr: Virtual Desktop-style desktop overlay
  # - proton-ge-rtsp-bin: Proton GE with OpenXR + low-latency patches
  #
  # For more details, see: https://github.com/nix-community/nixpkgs-xr

  services.wivrn = {
    enable = true;
    autoStart = false;
    openFirewall = true;
    steam.importOXRRuntimes = true;
    package = pkgs.wivrn;

    # Configuration to be set once I have it figured out. See: https://mynixos.com/nixpkgs/option/services.wivrn.config.json
    # config = {
    #   enable = false;
    #   config.json = {};
    # };
  };

  environment.systemPackages = with pkgs; [
    # System packages from regular channel
    # Provides adb for working with Meta Quest 3 and 3s.
    android-tools
    sidequest

    # XR packages from nixpkgs-xr overlay
    # OpenVR→OpenXR translation: lets SteamVR-only titles run via WiVRn/Monado
    # xrizer is the modern replacement for opencomposite (fallback)
    xrizer
    opencomposite

    # WayVR: Virtual Desktop-style desktop overlay inside VR
    # Run with: steam-run wayvr (required on NixOS due to Steam FHS sandbox)
    wayvr
  ];

  # Proton GE builds with OpenXR runtime support, for running SteamVR-only
  # titles via WiVRn/Monado. Includes low-latency patches relevant to VR
  # streaming. This must be registered as a Steam compatibility tool rather
  # than added to environment.systemPackages, since the package is a single
  # file (not a directory tree) and cannot be merged into the system path by
  # pkgs.buildEnv.
  # Source: nixpkgs-xr overlay
  programs.steam.extraCompatPackages = [ pkgs.proton-ge-rtsp-bin ];
}
