{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
    };

    # Optional: Declarative tap management
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-1password = {
      url = "github:1password/homebrew-tap";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      plasma-manager,
      sops-nix,
      nix-darwin,
      nix-homebrew,
      homebrew-core,
      homebrew-cask,
      homebrew-1password,
      ...
    }:
    {
      nixosConfigurations = {
        pho3nixf1re-nixos = nixpkgs.lib.nixosSystem {
          modules = [
            ./hosts/pho3nixf1re-nixos/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.sharedModules = [
                plasma-manager.homeModules.plasma-manager
                sops-nix.homeManagerModules.sops
              ];
              home-manager.users.pho3nixf1re =
                { ... }:
                {
                  imports = [
                    ./profiles/personal.nix
                    ./profiles/desktop-system.nix
                    ./profiles/common.nix
                  ];
                };

              # Optionally, use home-manager.extraSpecialArgs to pass
              # arguments to home.nix
            }
          ];
        };

        homeConfigurations."deck@steamdeck" = home-manager.lib.homeManagerConfiguration {
          modules = [
            sops-nix.homeManagerModules.sops
            ./hosts/steam-deck/home.nix
            ./profiles/personal.nix
            ./profiles/common.nix
          ];
        };
      };

      darwinConfigurations = {
        cvent-macos = nix-darwin.lib.darwinSystem {
          modules = [
            nix-homebrew.darwinModules.nix-homebrew
            ./hosts/cvent-macos/configuration.nix
            ./modules/darwin/macos-apps.nix
            home-manager.darwinModules.home-manager
            {
              nix-homebrew = {
                enable = true;

                # Apple Silicon backwards compatibility: Also install Homebrew
                # under the default Intel prefix for Rosetta 2.
                enableRosetta = true;

                user = "mturney";

                # Automatically migrate existing Homebrew installations.
                autoMigrate = true;

                # Declarative tap management
                taps = {
                  "homebrew/homebrew-core" = homebrew-core;
                  "homebrew/homebrew-cask" = homebrew-cask;
                  "1password/homebrew-tap" = homebrew-1password;
                };
              };
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.sharedModules = [
                sops-nix.homeManagerModules.sops
              ];
              home-manager.users.mturney = {
                imports = [
                  ./profiles/cvent.nix
                  ./profiles/common.nix
                ];
              };
            }
            # Align homebrew taps config with nix-homebrew
            (
              { config, ... }:
              {
                homebrew.taps = builtins.attrNames config.nix-homebrew.taps;
              }
            )
          ];
        };
      };
    };
}
