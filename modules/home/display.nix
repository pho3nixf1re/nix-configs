{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  options.custom.display = {
    server = mkOption {
      type = types.enum [
        "wayland"
        "x11"
      ];
      default = "wayland";
      description = "The display server protocol in use. Controls Wayland vs X11-specific packages and environment variables.";
    };
  };

  config = mkMerge [
    (mkIf (config.custom.display.server == "wayland") {
      home.packages = with pkgs; [
        wl-clipboard
      ];

      systemd.user.sessionVariables = {
        # Enable native Wayland support for VS Code and other Electron apps.
        NIXOS_OZONE_WL = "1";
        # Enable Firefox Wayland support.
        MOZ_ENABLE_WAYLAND = "1";
      };
    })

    (mkIf (config.custom.display.server == "x11") {
      home.packages = with pkgs; [
        xclip
      ];
    })
  ];
}
