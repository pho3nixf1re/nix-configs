{ pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  boot.supportedFilesystems = [ "ntfs" ];

  # Auto-mount NTFS drives at boot (using labels for stability)
  fileSystems."/run/media/pho3nixf1re/Sabrent Rocket 2TB" = {
    device = "/dev/disk/by-label/Sabrent\\x20Rocket\\x202TB";
    fsType = "ntfs3";
    options = [
      "rw"
      "uid=1000"
      "gid=100"
      "dmask=022"
      "fmask=133"
      "force"
      "nofail"
    ];
  };

  fileSystems."/run/media/pho3nixf1re/850 Evo" = {
    device = "/dev/disk/by-label/850\\x20Evo";
    fsType = "ntfs3";
    options = [
      "rw"
      "uid=1000"
      "gid=100"
      "dmask=022"
      "fmask=133"
      "force"
      "nofail"
    ];
  };

  fileSystems."/run/media/pho3nixf1re/WD 5000" = {
    device = "/dev/disk/by-label/WD\\x205000";
    fsType = "ntfs3";
    options = [
      "rw"
      "uid=1000"
      "gid=100"
      "dmask=022"
      "fmask=133"
      "force"
      "nofail"
    ];
  };

  fileSystems."/run/media/pho3nixf1re/OCZ Vertex4" = {
    device = "/dev/disk/by-label/OCZ\\x20Vertex4";
    fsType = "ntfs3";
    options = [
      "rw"
      "uid=1000"
      "gid=100"
      "dmask=022"
      "fmask=133"
      "force"
      "nofail"
    ];
  };

  networking.hostName = "pho3nixf1re-nixos";

  # Enable networking
  networking.networkmanager.enable = true;
  # This was generated using `sudo su -c "cd /etc/NetworkManager/system-connections && nix --extra-experimental-features 'nix-command flakes' run github:Janik-Haag/nm2nix | nix --extra-experimental-features 'nix-command flakes' run nixpkgs#nixfmt-rfc-style"`
  networking.networkmanager.ensureProfiles.profiles = {
    "Wired connection 1" = {
      connection = {
        autoconnect-priority = "10";
        id = "Wired connection 1";
        type = "ethernet";
        uuid = "6e0e0c70-085e-3e24-9a60-c5ae7e6e9d46";
        interface-name = "enp39s0";
      };
      ethernet = { };
      ipv4 = {
        method = "auto";
      };
      ipv6 = {
        addr-gen-mode = "stable-privacy";
        method = "auto";
      };
      proxy = { };
    };
  };

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  # services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap for login screen.
  services.xserver.xkb = {
    layout = "us,us";
    variant = "dvorak,";
    options = "caps:swapescape,grp:alt_shift_toggle";
  };

  # Configure console keymap
  console.keyMap = "dvorak";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Fixes error "Failed to start Refresh fwupd metadata and update motd." when rebuilding.
  services.fwupd.enable = true;

  # Used to remap mouse buttons and other things.
  services.input-remapper.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  # Configure sudo timeout
  security.sudo = {
    enable = true;
    extraConfig = ''
      Defaults timestamp_timeout=60
    '';
    extraRules = [
      {
        users = [ "pho3nixf1re" ];
        commands = [
          {
            command = "${pkgs.cifs-utils}/bin/mount.cifs";
            options = [ "NOPASSWD" ];
          }
          {
            command = "${pkgs.util-linux}/bin/umount";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.pho3nixf1re = {
    isNormalUser = true;
    description = "Matthew Turney";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [
      kdePackages.kate
      kdePackages.yakuake
      #  thunderbird
    ];
    shell = pkgs.zsh;
  };

  services.flatpak.enable = true;
  environment.etc = {
    "flatpak/remotes.d/flathub.flatpakrepo".source = pkgs.fetchurl {
      url = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      # Let this run once and you will get the hash as an error.
      hash = "sha256-M3HdJQ5h2eFjNjAHP+/aFTzUQm9y9K+gwzc64uj+oDo=";
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Flakes clones its dependencies through the git command, so git must be installed first.
    git
  ];

  programs.zsh.enable = true;

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    # Certain features, including CLI integration and system authentication
    # support, require enabling PolKit integration on some desktop environments
    # (e.g. Plasma).
    polkitPolicyOwners = [ "pho3nixf1re" ];
  };

  hardware.bluetooth.enable = true;

  # Support for the xbox controller USB dongle.
  hardware.xone.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    gamescopeSession.enable = true;
    extraPackages = with pkgs; [
      jdk
    ];
  };

  programs.java.enable = true;

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
  ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Optimize store automatically
  nix.optimise = {
    automatic = true;
    dates = [ "weekly" ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
