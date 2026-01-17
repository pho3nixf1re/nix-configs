{ config, lib, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
  };

  xdg.configFile = builtins.listToAttrs (
    builtins.map (filename: {
      name = "zsh/conf.d/${filename}";
      value = {
        source = ./conf.d/${filename};
      };
    }) (builtins.attrNames (builtins.readDir ./conf.d))
  );

  programs.starship = lib.mkIf config.programs.zsh.enable {
    enable = true;
  };

  home.shell.enableZshIntegration = true;
}
