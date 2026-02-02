{
  # Iterm2 configuration folder. Point iterm2 to
  # `~/.config/iterm2/custom-settings` to load preferences. This symlinks the
  # entire folder so generated files and future additions are supported.
  xdg.configFile."iterm2/custom-settings" = {
    source = ./settings;
    recursive = true;
  };
}
