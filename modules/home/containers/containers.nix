{
  programs.lazydocker.enable = true;

  programs.docker-cli = {
    enable = true;
  };

  services.colima = {
    enable = true;
    startOnLogin = false;
  };
}
