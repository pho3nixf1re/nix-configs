{ localstackPkgs, ... }:

{
  home.packages = [
    localstackPkgs.localstack
  ];

  programs.awscli.enable = true;
}
