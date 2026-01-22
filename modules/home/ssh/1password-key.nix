{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.ssh.onePasswordKeys;

  keyModule = types.submodule {
    options = {
      onePasswordPath = mkOption {
        type = types.str;
        description = "Path to the SSH public key in 1Password (e.g., op://Vault/Item Name/public key)";
      };

      outputPath = mkOption {
        type = types.str;
        description = "Path where the public key should be written (relative to home directory)";
        example = ".ssh/mykey.pub";
      };
    };
  };

in
{
  options.ssh.onePasswordKeys = mkOption {
    type = types.attrsOf keyModule;
    default = { };
    description = "SSH public keys to extract from 1Password";
    example = literalExpression ''
      {
        cvent = {
          onePasswordPath = "op://Private/Github SSH Key/public key";
          outputPath = ".ssh/github.pub";
        };
      }
    '';
  };

  config = mkIf (cfg != { }) {
    home.activation = mkMerge [
      # Extract all configured keys.
      (mkIf (cfg != { }) {
        extractOnePasswordSshKeys = lib.hm.dag.entryAfter [ "writeBoundary" ] (
          let
            extractCommands = mapAttrsToList (name: keyCfg: ''
              echo "Extracting ${name} SSH public key from 1Password..."
              KEY_FILE="$HOME/${keyCfg.outputPath}"
              KEY_DIR=$(dirname "$KEY_FILE")
              mkdir -p "$KEY_DIR"

              # Check if 1Password desktop app is running
              if ! ${pkgs.procps}/bin/pgrep -x "1password" > /dev/null; then
                echo "Warning: 1Password desktop app not running. ${name} key extraction skipped."
              elif command -v op &> /dev/null; then
                ${pkgs._1password}/bin/op read "${keyCfg.onePasswordPath}" > "$KEY_FILE.tmp" 2>/dev/null && \
                  mv "$KEY_FILE.tmp" "$KEY_FILE" || \
                  echo "Warning: Could not extract ${name} SSH key from 1Password. Ensure you're signed in."
              else
                echo "Warning: 1Password CLI not found. ${name} SSH key not extracted."
              fi
            '') cfg;
          in
          concatStringsSep "\n" extractCommands
        );
      })

      # Clean up keys when module is removed
      (mkIf (cfg != { }) {
        cleanupOnePasswordSshKeys = lib.hm.dag.entryBefore [ "checkLinkTargets" ] (
          let
            cleanupCommands = mapAttrsToList (name: keyCfg: ''
              KEY_FILE="$HOME/${keyCfg.outputPath}"
              if [ -f "$KEY_FILE" ]; then
                echo "Removing ${name} SSH public key..."
                rm -f "$KEY_FILE"
              fi
            '') cfg;
          in
          concatStringsSep "\n" cleanupCommands
        );
      })
    ];
  };
}
