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
              example = "//nas/media";
            };

            mountPoint = mkOption {
              type = types.str;
              example = "mnt/nas";
            };

            mountOptions = mkOption {
              type = types.listOf types.str;
              default = [
                "file_mode=0644"
                "dir_mode=0755"
                "vers=3.1.1"
              ];
            };
          };
        }
      );
      default = { };
    };
  };

  config = mkIf cfg.enable {

    home.packages = [ pkgs.cifs-utils ];

    # sops env file per mount
    sops.secrets = mapAttrs' (
      name: _:
      nameValuePair "smb/${name}/env" {
        sopsFile = ../../secrets/smb.yaml;
        mode = "0400";
      }
    ) cfg.mounts;

    systemd.user.services = mapAttrs' (
      name: mount:
      let
        envFile = config.sops.secrets."smb/${name}/env".path;
        mountPoint = "${config.home.homeDirectory}/${mount.mountPoint}";

        extraOpts = concatStringsSep "," mount.mountOptions;

        mountCmd =
          "sudo -n mount -t cifs \"${mount.share}\" \"${mountPoint}\" "
          + "-o username=$SMB_USERNAME,password=$SMB_PASSWORD${
            optionalString (extraOpts != "") ",${extraOpts}"
          }";

        umountCmd = "sudo -n umount \"${mountPoint}\"";
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
          EnvironmentFile = envFile;

          ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${mountPoint}";
          ExecStart = "${pkgs.runtimeShell} -c ${lib.escapeShellArg mountCmd}";
          ExecStop = "${pkgs.runtimeShell} -c ${lib.escapeShellArg umountCmd}";

          StandardOutput = "journal";
          StandardError = "journal";
        };

        Install.WantedBy = [ "default.target" ];
      }
    ) cfg.mounts;
  };
}
