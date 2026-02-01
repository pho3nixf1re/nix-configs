{ pkgs, ... }:

{
  # For container monitoring on CLI.
  programs.lazydocker.enable = true;

  home.packages = with pkgs; [
    colima
    docker
    docker-compose
  ];
}
