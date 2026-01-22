{ lib, pkgs, ... }:
{
  xdg.configFile = {
    "zsh/conf.d/git.zsh".source = ./git.zsh;
    "git/gitconfig".source = ./gitconfig;
  };

  home.file = {
    ".gitignore".source = ./gitignore;
  };

  programs.git.extraConfig = lib.mkMerge [
    {
      include.path = "~/.config/git/gitconfig";
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

  # TODO: Link Windows gitconfig from WSL to Windows home path.
  # This should be a /mnt/c/Users/{username}/.gitconfig path.
  # home.file.".config/git/gitconfig-windows".source = ./gitconfig-windows;
}
