{
  description = "NixOS Virgin btw";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      # Shared modules used by all hosts
      commonModules = hostName: [
        ./modules/common.nix
        ./modules/gaming.nix
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.elias = import ./home.nix;
            backupFileExtension = "backup";
            extraSpecialArgs = {
              inherit hostName;
            };
          };
        }
        inputs.stylix.nixosModules.stylix
      ];
    in
    {
      nixosConfigurations = {
        nixos-virgin = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = commonModules "nixos-virgin" ++ [ ./hosts/laptop/configuration.nix ];
        };

        nixos-desktop = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = commonModules "nixos-desktop" ++ [ ./hosts/desktop/configuration.nix ];
        };
      };
    };
}
