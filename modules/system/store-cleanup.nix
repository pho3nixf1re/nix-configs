{
  # Garbage collect old generations automatically.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  nix.optimise = {
    automatic = true;
    dates = [ "weekly" ];
  };
}
