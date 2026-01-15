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
    enableDefaultConfig = false;
    includes = [
      "~/.ssh/config.d/*"
    ];

    matchBlocks."*" = {
      forwardAgent = false;
      addKeysToAgent = "no";
      compression = false;
      serverAliveInterval = 0;
      serverAliveCountMax = 3;
      hashKnownHosts = false;
      userKnownHostsFile = "~/.ssh/known_hosts";
      controlMaster = "no";
      controlPath = "~/.ssh/master-%r@%n:%p";
      controlPersist = "no";
      identityAgent = "${onePassPath}";
    };
  };

  # ssh-agent is handled by 1password.
  # services.ssh-agent.enable = true;
}
