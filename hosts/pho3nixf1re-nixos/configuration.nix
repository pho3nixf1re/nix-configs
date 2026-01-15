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

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
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
      #  thunderbird
    ];
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

  # Overlay to fix xone-dongle-firmware until PR #472163 is merged.
  nixpkgs.overlays = [
    (final: prev: {
      xone-dongle-firmware = prev.xow_dongle-firmware.overrideAttrs (old: {
        version = "0-unstable-2025-01-14";

        srcs = [
          (prev.fetchurl {
            url = "https://catalog.s.download.windowsupdate.com/d/msdownload/update/driver/drvs/2017/03/2ea9591b-f751-442c-80ce-8f4692cdc67b_6b555a3a288153cf04aec6e03cba360afe2fce34.cab";
            hash = "sha256-2Jpy6NwQt8TxbVyIf+f1TDTCIAWsHzYHBNXZRiJY7zI=";
          })
          (prev.fetchurl {
            url = "https://catalog.s.download.windowsupdate.com/c/msdownload/update/driver/drvs/2017/07/1cd6a87c-623f-4407-a52d-c31be49e925c_e19f60808bdcbfbd3c3df6be3e71ffc52e43261e.cab";
            hash = "sha256-ZXNqhP9ANmRbj47GAr7ZGrY1MBnJyzIz3sq5/uwPbwQ=";
          })
          (prev.fetchurl {
            url = "https://catalog.s.download.windowsupdate.com/c/msdownload/update/driver/drvs/2017/06/1dbd7cb4-53bc-4857-a5b0-5955c8acaf71_9081931e7d664429a93ffda0db41b7545b7ac257.cab";
            hash = "sha256-kN2R+2dGDTh0B/2BCcDn0PGPS2Wb4PYtuFihhJ6tLuA=";
          })
          (prev.fetchurl {
            url = "https://catalog.s.download.windowsupdate.com/d/msdownload/update/driver/drvs/2017/08/aeff215c-3bc4-4d36-a3ea-e14bfa8fa9d2_e58550c4f74a27e51e5cb6868b10ff633fa77164.cab";
            hash = "sha256-Wo+62VIeWMxpeoc0cgykl2cwmAItYdkaiL5DMALM2PI=";
          })
        ];

        unpackPhase = ''
          srcs=($srcs)
          cabextract -F FW_ACC_00U.bin ''${srcs[0]}
          mv FW_ACC_00U.bin xone_dongle_02e6.bin
          cabextract -F FW_ACC_00U.bin ''${srcs[1]}
          mv FW_ACC_00U.bin xone_dongle_02fe.bin
          cabextract -F FW_ACC_CL.bin ''${srcs[2]}
          mv FW_ACC_CL.bin xone_dongle_02f9.bin
          cabextract -F FW_ACC_BR.bin ''${srcs[3]}
          mv FW_ACC_BR.bin xone_dongle_091e.bin
        '';

        installPhase = ''
          mkdir -p $out/lib/firmware/
          cp xone_dongle_*.bin $out/lib/firmware/
        '';
      });
    })
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Flakes clones its dependencies through the git command, so git must be installed first.
    git
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
  ];

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    # Certain features, including CLI integration and system authentication
    # support, require enabling PolKit integration on some desktop environments
    # (e.g. Plasma).
    polkitPolicyOwners = [ "pho3nixf1re" ];
  };

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

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
