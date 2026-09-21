{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.duplicati;

  # Get hostname with fallback to environment variable.
  # Only used by the Linux systemd unit; macOS shells do not export
  # HOSTNAME and home-manager has no config.networking.hostName, so the
  # launchd agent relies on the system-reported machine name instead.
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

    trayIcon = mkEnableOption "the Duplicati tray icon (menu bar on macOS, system tray on Linux)";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = [ pkgs.duplicati ];
    }

    (mkIf pkgs.stdenv.hostPlatform.isLinux {
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

      # Menu bar / system tray icon, connects to the running service
      systemd.user.services.duplicati-tray-icon = mkIf cfg.trayIcon {
        Unit = {
          Description = "Duplicati Tray Icon (User)";
          Documentation = "https://www.duplicati.com/";
          After = [ "duplicati.service" ];
          Requires = [ "duplicati.service" ];
        };

          # --read-config-from-db lets the tray icon authenticate to the
          # running service by reading the connection info from its database
          Service = {
            Type = "simple";
            ExecStart = "${pkgs.duplicati}/bin/duplicati --no-hosted-server --read-config-from-db --server-datafolder=${cfg.dataDir} --webservice-port=${toString cfg.port}";
            Restart = "on-failure";
            RestartSec = "10s";
          };

        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };
    })

    (mkIf pkgs.stdenv.hostPlatform.isDarwin {
      launchd.agents.duplicati = {
        enable = true;
        config = {
          # Duplicati creates --server-datafolder itself if missing.
          ProgramArguments = [
            "${pkgs.duplicati}/bin/duplicati-server"
            "--webservice-port=${toString cfg.port}"
            "--server-datafolder=${cfg.dataDir}"
          ];
          # Start at login (gui domain), restart only on non-zero exit
          # (equivalent to systemd's Restart=on-failure), throttled to
          # ThrottleInterval (equivalent to RestartSec=10s).
          RunAtLoad = true;
          KeepAlive.SuccessfulExit = false;
          ThrottleInterval = 10;
          ProcessType = "Background";
          StandardOutPath = "${config.home.homeDirectory}/Library/Logs/duplicati.log";
          StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/duplicati.err.log";
        };
      };

      # Menu bar icon, connects to the running service
      launchd.agents.duplicati-tray-icon = mkIf cfg.trayIcon {
        enable = true;
        config = {
          # --read-config-from-db lets the tray icon authenticate to the
          # running service by reading the connection info from its database
          ProgramArguments = [
            "${pkgs.duplicati}/bin/duplicati"
            "--no-hosted-server"
            "--read-config-from-db"
            "--server-datafolder=${cfg.dataDir}"
            "--webservice-port=${toString cfg.port}"
          ];
          RunAtLoad = true;
          KeepAlive.SuccessfulExit = false;
          StandardOutPath = "${config.home.homeDirectory}/Library/Logs/duplicati-tray-icon.log";
          StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/duplicati-tray-icon.err.log";
        };
      };
    })
  ]);
}
