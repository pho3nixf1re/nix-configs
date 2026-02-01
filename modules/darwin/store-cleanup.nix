{
  # Garbage collect old generations automatically.
  nix.gc = {
    automatic = true;
    interval = [
      {
        Hour = 3;
        Minute = 15;
        Weekday = 7;
      }
    ];
    options = "--delete-older-than 30d";
  };

  nix.optimise = {
    automatic = true;
    interval = [
      {
        Hour = 4;
        Minute = 0;
        Weekday = 7;
      }
    ];
  };
}
