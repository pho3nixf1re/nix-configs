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
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      plasma-manager,
      sops-nix,
      nix-darwin,
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
                    ./profiles/dev.nix
                    ./profiles/desktop-system.nix
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
            ./profiles/dev.nix
          ];
        };
      };

      darwinConfigurations = {
        cvent-macos = nix-darwin.lib.darwinSystem {
          modules = [
            ./hosts/cvent-macos/configuration.nix
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.sharedModules = [
                sops-nix.homeManagerModules.sops
              ];
              home-manager.users.mturney = {
                imports = [
                  ./profiles/cvent.nix
                ];
              };
            }
          ];
        };
      };
    };
}
