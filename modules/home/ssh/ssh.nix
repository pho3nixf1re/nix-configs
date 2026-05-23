{
  programs.ssh = {
    enable = true;
    # Deprecated attribute, using * match block instead.
    enableDefaultConfig = false;
    includes = [
      "~/.ssh/config.d/*"
    ];

    settings = {
      "*" = {
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
        identityAgent = "~/.1password/agent.sock";
      };
      "nas.feliciterra.com" = {
        hostname = "10.0.0.105";
        user = "mturney";
        identityFile = "~/.ssh/feliciterra_nas.pub";
        identitiesOnly = true;
      };
      "homeassistant.feliciterra.com" = {
        hostname = "10.0.0.101";
        user = "root";
        identityFile = "~/.ssh/feliciterra_homeassistant.pub";
        identitiesOnly = true;
      };
      "github.com" = {
        user = "git";
        identityFile = "~/.ssh/github.pub";
        identitiesOnly = true;
      };
    };
  };

  # Copy all public keys from the public-keys directory to `~/.ssh`.
  home.file.".ssh" = {
    source = ./public-keys;
    recursive = true;
  };

  # ssh-agent is handled by 1password.
  # services.ssh-agent.enable = true;
}
