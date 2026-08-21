{
  pkgs,
  config,
  lib,
  ...
}:
let
  cventPubKey = lib.strings.trim (builtins.readFile ./cvent.pub);
in

{
  # Gitconfig for Cvent work points ssh command to this file.
  home.file.".ssh/ssh_config_cvent".source = ./ssh_config_cvent;
  home.file.".ssh/cvent.pub".source = ./cvent.pub;

  xdg.configFile = {
    "git/cvent.gitconfig".source = ./cvent.gitconfig;
    "git/allowed_signers".text = lib.mkAfter ''
      mturney@cvent.com ${cventPubKey}
    '';
  };

  programs.git.settings = {
    includeIf."gitdir:~/Workspace/socialtables/".path = "~/.config/git/cvent.gitconfig";
  };

  home.packages = with pkgs; [
    # Local development environment dependencies.
    poppler
    vips
  ];

  # Add iterm-automation alias that executes the iterm2 services launcher
  programs.zsh.shellAliases = lib.mkIf config.programs.zsh.enable {
    st-run = "nix develop --impure \"$NIX_FLAKE_PATH#iterm-automation\" --command python ~/Workspace/socialtables/repo-runner/launchers/iterm2/services.py";
  };

  # Global oxfmt config – matches SocialTables' Prettier style.
  # Only options that differ from oxfmt's own defaults are listed.
  home.file.".oxfmtrc.json".text = builtins.toJSON {
    "$schema" =
      "https://raw.githubusercontent.com/oxc-project/oxc/main/npm/oxfmt/configuration_schema.json";
    bracketSpacing = false;
    printWidth = 80;
    singleQuote = true;
    trailingComma = "es5";
  };

  # Combined CA certificate created with Netskope must exist in a variety of session variables.
  home.sessionVariables = {
    _NS_COMBINED_CERT = "${config.xdg.configHome}/ssl/nscacert.pem";
    PATH = "$HOME/.cargo/bin:$PATH";
  };

  xdg.configFile."zsh/conf.d/setup-certs.zsh".source = ./setup-certs.zsh;

  # wget needs to use combined cert from Netskope.
  home.file.".wgetrc".text = ''
    ca-certificate=${config.xdg.configHome}/ssl/nscacert.pem
  '';
}
