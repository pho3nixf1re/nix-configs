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
        include.path = "~/.config/git/common.gitconfig";
      }

      # Linux-specific config
      (lib.mkIf pkgs.stdenv.isLinux {
        credential.helper = "/run/current-system/sw/bin/git-credential-manager";
        credential.credentialStore = "secretservice";
        merge.tool = "vim";
      })

      # macOS-specific config
      (lib.mkIf pkgs.stdenv.isDarwin {
        gpg.ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
      })
    ];
  };

  # TODO: Link Windows gitconfig from WSL to Windows home path.
  # This should be a /mnt/c/Users/{username} path. Something like:
  # "/mnt/c/Users/{username}/.config/git/config".source = ./windows.gitconfig;
}
