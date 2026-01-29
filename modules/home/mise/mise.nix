{
  programs.mise = {
    enable = true;
    enableZshIntegration = true;
    globalConfig = {
      tools = {
        nodejs = "system";
        python = "system";
        pnpm = "latest";
      };
      settings = {
        idiomatic_version_file_enable_tools = [
          "node"
          "python"
        ];
        # env_file = ".env"
      };
    };
  };
}
