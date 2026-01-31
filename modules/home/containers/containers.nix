{ pkgs, ... }:

{
  programs.lazydocker.enable = true;

  programs.docker-cli = {
    enable = true;
  };

  home.packages = with pkgs; [
    colima
    docker
    docker-compose
  ];
}
