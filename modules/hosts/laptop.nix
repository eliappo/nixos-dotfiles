# flake-parts module — registers nixosConfigurations.nixos-virgin
{ inputs, ... }:

{
  flake.nixosConfigurations.nixos-virgin = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      ../../hosts/laptop/hardware-configuration.nix
      ../../nixos/default.nix

      {
        networking.hostName = "nixos-virgin";

        # GPU — NVIDIA with power management for battery
        services.xserver.videoDrivers = [ "nvidia" ];
        hardware.nvidia.open = true;
        hardware.nvidia.powerManagement.enable = true;

        # Casual Steam on laptop (no gamescope/TV console setup)
        programs.steam.enable = true;
        hardware.graphics.enable32Bit = true;

        # Gaming module off on laptop
        custom.gaming.enable = false;

        home-manager.extraSpecialArgs = { hostName = "nixos-virgin"; };
        home-manager.users.elias.imports = [ ../../home/default.nix ];
      }
    ];
  };
}
