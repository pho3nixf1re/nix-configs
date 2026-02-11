{ pkgs, ... }:

{
  # Might put this in a server on the NAS.
  # home.packages = with pkgs; [
  #   libation
  # ];

  programs.calibre = {
    enable = true;
  };
}
