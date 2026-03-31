{ pkgs, ... }:

{
  home.packages = [
    pkgs.localstack
  ];

  programs.awscli.enable = true;
}
