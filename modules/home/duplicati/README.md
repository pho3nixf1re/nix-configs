# Duplicati Backup Module

A home-manager module for running [Duplicati](https://www.duplicati.com/) as a user-level service. This module is designed to work on both NixOS and non-NixOS systems (like SteamOS).

## Features

- **User-level systemd service** - Runs in user context, no system privileges required
- **Desktop-only auto-start** - Automatically starts only in graphical sessions (`graphical-session.target`)
- **Configurable web UI port** - Default 8200, easily overridable per-host
- **Automatic backup directory creation** - Creates `~/mnt/feliciterra/backups/<hostname>` for backup storage
- **SMB mount integration** - Optionally waits for SMB mounts before starting
- **Cross-platform hostname detection** - Uses `config.networking.hostName` on NixOS, falls back to `$HOSTNAME` environment variable

## Configuration Options

```nix
services.duplicati = {
  enable = true;  # Enable the Duplicati service

  port = 8200;  # Web UI port (default: 8200)

  dataDir = ".local/share/duplicati";  # Duplicati data directory (relative to ~)

  backupBasePath = "mnt/feliciterra/backups";  # Base path for backups (relative to ~)
};
```

## Usage

### Enable on NixOS

In your `flake.nix` or host configuration:

```nix
home-manager.users.yourusername = {
  services.duplicati.enable = true;
};
```

### Enable on SteamOS

In your home-manager configuration:

```nix
{
  services.duplicati.enable = true;
}
```

### Override Port Per-Host

If you need different ports on different machines:

```nix
# On host 1
services.duplicati = {
  enable = true;
  port = 8200;
};

# On host 2
services.duplicati = {
  enable = true;
  port = 8201;
};
```

### Custom Backup Path

```nix
services.duplicati = {
  enable = true;
  backupBasePath = "backups/duplicati";  # Will use ~/backups/duplicati/<hostname>
};
```

## Backup Storage Location

By default, backups are stored at:
```
~/mnt/feliciterra/backups/<hostname>/
```

Where `<hostname>` is:
- On NixOS: From `config.networking.hostName`
- On other systems: From `$HOSTNAME` environment variable

This directory is automatically created during home-manager activation.

## Accessing the Web UI

Once the service is running, access the Duplicati web interface at:
```
http://localhost:8200
```

(Or whatever port you configured)

## Service Management

### Start/Stop/Status

```bash
# Check service status
systemctl --user status duplicati

# Start manually (auto-starts on login to desktop session)
systemctl --user start duplicati

# Stop service
systemctl --user stop duplicati

# Restart service
systemctl --user restart duplicati

# View logs
journalctl --user -u duplicati -f
```

### Disable Auto-Start

The service automatically starts when you log into a graphical session. If you want to run it manually:

```nix
services.duplicati = {
  enable = true;
  # Override the systemd service to remove auto-start
};

systemd.user.services.duplicati.Install.WantedBy = lib.mkForce [];
```

## Backup Configuration

Duplicati stores its configuration in `~/.local/share/duplicati/` by default. This includes:
- Backup job definitions
- Database of backed-up files
- Encryption keys (if using encrypted backups)
- Application settings

**Note:** This module does **not** use encrypted backups because the secondary backup destination (backup-to-backup) uses end-to-end encryption. Backups are stored in plain format on the SMB share.

### Setting Up Your First Backup

1. Open the web UI: `http://localhost:8200`
2. Click "Add backup"
3. Configure your backup:
   - **Encryption:** Choose "No encryption" (recommended for this setup)
   - **Destination:** Select "Local folder or drive"
   - **Path:** Use `~/mnt/feliciterra/backups/<hostname>/backup-name`
   - **Source:** Select the files/folders you want to back up
   - **Schedule:** Configure when backups should run

## Dependencies

### Required

- SMB mount or other backup storage must be available at the backup path
- This module does **not** automatically enable `services.smb-mounts`

### Optional Dependencies

If you're using the Feliciterra SMB mount module:

```nix
# Enable both modules
services.smb-mounts.enable = true;
services.duplicati.enable = true;
```

The Duplicati service will automatically wait for `smb-mount-feliciterra.service` to be available (using systemd `After` directive), but it won't fail if the mount isn't present.

## Cross-Platform Notes

### NixOS

- Full integration with systemd
- Hostname automatically detected from system configuration
- Service auto-starts in desktop sessions (KDE Plasma, GNOME, etc.)

### SteamOS / Steam Deck

- Works in Desktop Mode only (gaming mode doesn't start user graphical sessions)
- Uses `$HOSTNAME` environment variable for hostname detection
- All data stored in `~/.local/share/` (persistent across SteamOS updates)
- SMB mounts must be set up separately if using network storage

## Troubleshooting

### Service won't start

Check the logs:
```bash
journalctl --user -u duplicati -n 50
```

Common issues:
- Backup path doesn't exist → Check if SMB mount is working
- Port already in use → Change the port in configuration
- Hostname not detected → Set `$HOSTNAME` environment variable

### Can't access web UI

1. Verify service is running:
   ```bash
   systemctl --user status duplicati
   ```

2. Check which port it's using:
   ```bash
   ss -tlnp | grep duplicati
   ```

3. Try accessing on the configured port

### Hostname shows as empty

On non-NixOS systems, set the `HOSTNAME` environment variable:

```bash
export HOSTNAME="my-hostname"
```

Or add it to your shell configuration.

### Backups fail with permission errors

Ensure the user running Duplicati (you) has:
- Read access to source files
- Write access to backup destination (`~/mnt/feliciterra/backups/<hostname>`)

## Module Files

- **Module:** [duplicati.nix](duplicati.nix)
- **Documentation:** This file

## Related Modules

- [feliciterra-fileshares](../feliciterra-fileshares/) - SMB mount module that provides the backup storage
- [1password](../1password/) - 1Password integration for secrets management

## License

MIT
