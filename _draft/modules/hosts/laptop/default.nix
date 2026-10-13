# DRAFT — modules/hosts/laptop/default.nix
#
# Same structure as desktop. The differences from desktop are:
#   - No RTL8812AU wifi dongle
#   - NVIDIA power management enabled (laptop battery)
#   - Gaming module disabled (no gamescope/TV setup)
#   - Steam still enabled manually (casual gaming)
#   - Different monitor symlink

{ inputs, config, withSystem, ... }:

{
  flake.nixosConfigurations.nixos-virgin = withSystem "x86_64-linux" (
    { pkgs, ... }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit pkgs;
      modules =
        [ ./hardware-configuration.nix ]
        ++ builtins.attrValues config.flake.modules.nixos
        ++ [{
          networking.hostName = "nixos-virgin";

          # Laptop GPU: NVIDIA with power management
          services.xserver.videoDrivers = [ "nvidia" ];
          hardware.nvidia.open = true;
          hardware.nvidia.powerManagement.enable = true;

          # Casual Steam on laptop without the full gaming/gamescope setup
          programs.steam.enable = true;
          hardware.graphics.enable32Bit = true;

          # Gaming module off on laptop (gamescope/TV console not needed)
          custom.gaming.enable = false;

          home-manager.users.elias = {
            imports = builtins.attrValues config.flake.modules.homeManager;
            home.file.".config/hypr/monitors.conf" = {
              source = config.lib.file.mkOutOfStoreSymlink
                "/home/elias/nixos-dotfiles/config/hypr/monitors-nixos-virgin.conf";
            };
          };
        }];
    }
  );
}
