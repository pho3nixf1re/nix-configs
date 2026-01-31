{ lib, pkgs, ... }:
{
  xdg.configFile = {
    "zsh/conf.d/git.zsh".source = ./git.zsh;
    "git/common.gitconfig".source = ./common.gitconfig;
  };

  home.file = {
    ".gitignore".source = ./gitignore;
  };

  home.packages = with pkgs; [
    git-extras
  ];

  programs.git = {
    enable = true;
    settings = lib.mkMerge [
      {
        include.path = [
          "~/.config/git/common.gitconfig"
          # Used for local, non-tracked overrides.
          "~/.config/git/local.gitconfig"
        ];
      }

      # Linux-specific config
      (lib.mkIf pkgs.stdenv.isLinux {
        credential.helper = "/run/current-system/sw/bin/git-credential-manager";
        credential.credentialStore = "secretservice";
        merge.tool = "vim";
      })

      # MacOS-specific config
      (lib.mkIf pkgs.stdenv.isDarwin {
        gpg.ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
      })
    ];
  };

  # TODO: Link Windows gitconfig from WSL to Windows home path.
  # This should be a /mnt/c/Users/{username} path. Something like:
  # "/mnt/c/Users/{username}/.config/git/config".source = ./windows.gitconfig;

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      side-by-side = true;
      line-numbers = true;
      syntax-theme = "Solarized (dark)";
      features = "decorations";
      decorations = {
        commit-decoration-style = "blue ol";
        commit-style = "raw";
        file-style = "omit";
        hunk-header-decoration-style = "blue box";
        hunk-header-file-style = "red";
        hunk-header-line-number-style = "#067a00";
        hunk-header-style = "file line-number syntax";
      };
      interactive = {
        keep-plus-minus-markers = false;
      };
    };
  };
}
