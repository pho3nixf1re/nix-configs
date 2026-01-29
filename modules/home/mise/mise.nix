{
  programs.mise = {
    enable = true;
    enableZshIntegration = true;
    globalConfig = {
      tools = {
        nodejs = "latest";
        python = "3";
        # TODO: replace with temurin-11 or newer?
        # java = "adoptopenjdk-11.0.21+9";
        pnpm = "latest";
      };
    };

    settings = {
      idiomatic_version_file_enable_tools = [
        "node"
        "python"
      ];
      # env_file = ".env"
    };
  };
}
