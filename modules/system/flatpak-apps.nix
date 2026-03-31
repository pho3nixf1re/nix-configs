let
  packages = import ../shared/flatpak-packages.nix;
in
{
  services.flatpak = {
    enable = true;

    # Keep unmanaged apps/remotes installed via GUI or CLI tools.
    uninstallUnmanaged = false;

    inherit packages;
  };
}
