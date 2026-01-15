_:
let
  onePassPath = "~/.1password/agent.sock";
in
{
  # TODO: Copy cvent ssh config over but only on that host.
  home.file.".ssh/config.d/hosts.conf" = {
    source = ./ssh_config;
  };

  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host *
          IdentityAgent ${onePassPath}
    '';
    includes = [
      "~/.ssh/config.d/*"
    ];
  };
}
