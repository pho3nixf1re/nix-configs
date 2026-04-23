{ lib, config, ... }:

{
  programs.lazygit = {
    enable = true;
    settings = {
      os = {
        editPreset = "nvim";
      }
      // lib.optionalAttrs config.programs.mise.enable {
        environ = {
          PATH = "$HOME/.local/share/mise/shims:$PATH";
        };
      };
    };
  };
}
