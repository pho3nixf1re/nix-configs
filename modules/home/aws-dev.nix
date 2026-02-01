{ pkgs, ... }:

{
  home.packages = with pkgs; [
    localstack
  ];

  programs.awscli.enable = true;
}
