# flake-parts module — registers nixosConfigurations.nixos-virgin
{ inputs, ... }:

{
  flake.nixosConfigurations.nixos-virgin = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      ./_hardware-configuration.nix
      ../../../nixos/default.nix

      {
        networking.hostName = "nixos-virgin";

        # GPU with power management for battery life
        custom.nvidia.enable = true;
        custom.nvidia.powerManagement = true;

        # Gaming module off — gamescope/TV console not needed on laptop
        custom.gaming.enable = false;

        # Casual Steam without the full gaming setup
        programs.steam.enable = true;
        hardware.graphics.enable32Bit = true;

        home-manager.users.elias.imports = [ ../../../home/default.nix ];
      }
    ];
  };
}
