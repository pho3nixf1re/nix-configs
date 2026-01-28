{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.duplicati;

  # Get hostname with fallback to environment variable
  hostname = config.networking.hostName or (builtins.getEnv "HOSTNAME");
in
{
  options.services.duplicati = {
    enable = mkEnableOption "Duplicati backup service (user-level)";

    port = mkOption {
      type = types.int;
      default = 8200;
      description = "Port for Duplicati web UI";
    };

    dataDir = mkOption {
      type = types.str;
      default = "${config.xdg.dataHome}/duplicati";
      description = "Directory for Duplicati data";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.duplicati ];

    systemd.user.services.duplicati = {
      Unit = {
        Description = "Duplicati Backup Service (User)";
        Documentation = "https://www.duplicati.com/";
        After = [
          "network-online.target"
          "smb-mount-feliciterra.service"
        ];
        Wants = [ "network-online.target" ];
      };

      Service = {
        Type = "simple";
        ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${cfg.dataDir}";
        ExecStart = "${pkgs.duplicati}/bin/duplicati-server --webservice-port=${toString cfg.port} --server-datafolder=${cfg.dataDir}";
        Restart = "on-failure";
        RestartSec = "10s";
        Environment = [
          "HOSTNAME=${hostname}"
        ];
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
