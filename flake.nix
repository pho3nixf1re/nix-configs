{
  description = "NixOS configuration";

  inputs = {
    # System channel — updated deliberately (kernel, Plasma, system-level packages)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # Application channel — updated frequently (HM packages, apps, devShells)
    nixpkgs-latest.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      # home-manager follows the fast channel so HM packages stay current
      inputs.nixpkgs.follows = "nixpkgs-latest";
    };
    import-tree.url = "github:vic/import-tree";
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs-latest";
      inputs.home-manager.follows = "home-manager";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-latest";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-latest";
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
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-latest,
      home-manager,
      plasma-manager,
      sops-nix,
      nix-darwin,
      nix-homebrew,
      homebrew-core,
      homebrew-cask,
      ...
    }:
    let
      deckPkgs = import nixpkgs-latest {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
      localstackFixOverlay = final: prev: {
        # plux's test suite asserts dist.metadata["License"] == "MIT" using pytest
        # as a test fixture. This broke in pytest >= 8.1, which adopted PEP 639's
        # SPDX license format — moving license info to a "License-Expression" core
        # metadata field and leaving the legacy "License" field returning None.
        # This is a bug in plux's test, not in plux itself.
        #
        # PEP 639 (license metadata overhaul): https://peps.python.org/pep-0639/
        # pytest changelog: https://github.com/pytest-dev/pytest/blob/main/CHANGELOG.rst
        python3 = prev.python3.override {
          packageOverrides = self: super: {
            plux = super.plux.overrideAttrs (old: {
              pytestFlagsArray = (old.pytestFlagsArray or [ ]) ++ [
                "--deselect=tests/test_metadata.py::test_resolve_distribution_information"
              ];
            });
          };
        };
      };
      primaryUser = "pho3nixf1re";
      primaryUserSopsAgeKeyFile = "/home/${primaryUser}/.config/sops/age/keys.txt";
    in
    {
      nixosConfigurations = {
        pho3nixf1re-nixos = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit primaryUser;
            sopsAgeKeyFile = primaryUserSopsAgeKeyFile;
            # Available in any system module for packages that need to be on
            # the latest channel (e.g. a driver not yet in the pinned system
            # channel).
            pkgsLatest = import nixpkgs-latest {
              system = "x86_64-linux";
              config.allowUnfree = true;
            };
          };
          modules = [
            (
              { pkgs, ... }:
              {
                home-manager.extraSpecialArgs = {
                  inherit primaryUser;
                  sopsAgeKeyFile = primaryUserSopsAgeKeyFile;
                  # pkgsSystem gives HM modules access to the slow-pinned system
                  # channel. Use this for packages that must match the running
                  # system (e.g. kdePackages — Konsole/Yakuake must match Plasma).
                  pkgsSystem = pkgs;
                };
              }
            )
            ./hosts/pho3nixf1re-nixos/configuration.nix
            ./modules/system/common.nix
            ./modules/system/store-cleanup.nix
            ./modules/system/vr.nix
            ./modules/system/utils.nix
            ./modules/system/wireless-ap
            ./modules/system/wired-vr-router
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
            {
              # useGlobalPkgs = false so HM evaluates its own nixpkgs instance
              # from the nixpkgs-latest channel (via home-manager's follows),
              # keeping apps up-to-date independently of the pinned system channel.
              home-manager.useGlobalPkgs = false;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.sharedModules = [
                plasma-manager.homeModules.plasma-manager
                sops-nix.homeManagerModules.sops
              ];
              home-manager.users = {
                ${primaryUser} =
                  { ... }:
                  {
                    nixpkgs = {
                      config.allowUnfree = true;
                      # localstackFixOverlay applies here in HM where localstack lives,
                      # rather than at the system level.
                      overlays = [ localstackFixOverlay ];
                    };
                    imports = [
                      ./hosts/pho3nixf1re-nixos/home.nix
                      ./profiles/personal.nix
                      ./profiles/desktop-system.nix
                      ./profiles/common.nix
                    ];
                  };
              };
            }
          ];
        };
      };

      homeConfigurations."deck" = home-manager.lib.homeManagerConfiguration {
        pkgs = deckPkgs;
        modules = [
          plasma-manager.homeModules.plasma-manager
          sops-nix.homeManagerModules.sops
          ./hosts/steam-deck/home.nix
          ./profiles/personal.nix
          ./profiles/common.nix
        ];
      };

      darwinConfigurations = {
        cvent-macos = nix-darwin.lib.darwinSystem {
          modules = [
            {
              nixpkgs.overlays = [ localstackFixOverlay ];
            }
            nix-homebrew.darwinModules.nix-homebrew
            ./hosts/cvent-macos/configuration.nix
            ./modules/darwin/macos-apps.nix
            ./modules/darwin/appearance.nix
            ./modules/darwin/store-cleanup.nix
            ./modules/system/common.nix
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

      devShells =
        nixpkgs-latest.lib.genAttrs [ "x86_64-darwin" "aarch64-darwin" "x86_64-linux" "aarch64-linux" ]
          (system: {
            database-tools = (
              import ./modules/shells/database-tools.nix {
                nixpkgs = nixpkgs-latest;
                inherit system;
              }
            );
            iterm-automation = (
              import ./modules/shells/iterm-automation.nix {
                nixpkgs = nixpkgs-latest;
                inherit system;
              }
            );
          });
    };
}
