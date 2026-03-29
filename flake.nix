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
    import-tree.url = "github:vic/import-tree";
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

    # Fork of nixpkgs with a fixed localstack package (localstack-ext dependency)
    nixpkgs-localstack.url = "github:pho3nixf1re/nixpkgs/776e3672eef113cac43707ca7355d77d6544ac94";

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
      nixpkgs-localstack,
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
      deckPkgs = import nixpkgs {
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
      makeLocalstackPkgs =
        system:
        import nixpkgs-localstack {
          inherit system;
          config.allowUnfree = true;
          overlays = [ localstackFixOverlay ];
        };
    in
    {
      nixosConfigurations = {
        pho3nixf1re-nixos = nixpkgs.lib.nixosSystem {
          modules = [
            { nixpkgs.overlays = [ localstackFixOverlay ]; }
            (
              { pkgs, ... }:
              {
                home-manager.extraSpecialArgs = {
                  localstackPkgs = makeLocalstackPkgs pkgs.system;
                };
              }
            )
            ./hosts/pho3nixf1re-nixos/configuration.nix
            ./modules/system/common.nix
            ./modules/system/store-cleanup.nix
            ./modules/system/vr.nix
            ./modules/system/utils.nix
            ./modules/system/wireless-ap
            sops-nix.nixosModules.sops
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
                    ./hosts/pho3nixf1re-nixos/home.nix
                    ./profiles/personal.nix
                    ./profiles/desktop-system.nix
                    ./profiles/common.nix
                  ];
                };
            }
          ];
        };
      };

      homeConfigurations."deck" = home-manager.lib.homeManagerConfiguration {
        pkgs = deckPkgs;
        extraSpecialArgs = {
          localstackPkgs = makeLocalstackPkgs deckPkgs.stdenv.hostPlatform.system;
        };
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
            (
              { pkgs, ... }:
              {
                home-manager.extraSpecialArgs = {
                  localstackPkgs = makeLocalstackPkgs pkgs.stdenv.hostPlatform.system;
                };
              }
            )
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
        nixpkgs.lib.genAttrs [ "x86_64-darwin" "aarch64-darwin" "x86_64-linux" "aarch64-linux" ]
          (system: {
            database-tools = (import ./modules/shells/database-tools.nix { inherit nixpkgs system; });
            iterm-automation = (import ./modules/shells/iterm-automation.nix { inherit nixpkgs system; });
          });
    };
}
