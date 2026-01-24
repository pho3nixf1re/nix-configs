{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.smb-mounts;
in
{
  options.services.smb-mounts = {
    enable = mkEnableOption "SMB network mounts";

    mounts = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            share = mkOption {
              type = types.str;
              description = "SMB share path (e.g., //server/share)";
              example = "//nas/media";
            };

            mountPoint = mkOption {
              type = types.str;
              description = "Local mount point (relative to home directory)";
              example = "mnt/nas";
            };

            mountOptions = mkOption {
              type = types.listOf types.str;
              default = [
                "uid=%U"
                "gid=%G"
                "file_mode=0644"
                "dir_mode=0755"
                "vers=3.0"
              ];
              description = "Additional mount options";
            };
          };
        }
      );
      default = { };
      description = "SMB shares to mount";
    };
  };

  config = mkIf cfg.enable {
    # Install required packages
    home.packages = [ pkgs.cifs-utils ];

    # Configure sops secrets for each mount
    sops.secrets = mapAttrs' (
      name: mount:
      nameValuePair "smb/${name}/credentials" {
        sopsFile = ../../secrets/smb.yaml;
        mode = "0600";
      }
    ) cfg.mounts;

    # Create systemd services for each mount
    systemd.user.services = mapAttrs' (
      name: mount:
      let
        mountPoint = "${config.home.homeDirectory}/${mount.mountPoint}";
        credentialsFile = config.sops.secrets."smb/${name}/credentials".path;
        mountOptionsStr = concatStringsSep "," ([ "credentials=${credentialsFile}" ] ++ mount.mountOptions);
      in
      nameValuePair "smb-mount-${name}" {
        Unit = {
          Description = "Mount SMB share: ${mount.share}";
          After = [ "network-online.target" ];
          Wants = [ "network-online.target" ];
        };

        Service = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${mountPoint}";
          ExecStart = "/run/wrappers/bin/sudo ${pkgs.cifs-utils}/bin/mount.cifs ${mount.share} ${mountPoint} -o ${mountOptionsStr}";
          ExecStop = "/run/wrappers/bin/sudo ${pkgs.util-linux}/bin/umount ${mountPoint}";
          Restart = "on-failure";
          RestartSec = "30s";
        };

        Install = {
          WantedBy = [ "default.target" ];
        };
      }
    ) cfg.mounts;
  };
}
