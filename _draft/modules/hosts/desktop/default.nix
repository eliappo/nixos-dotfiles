# DRAFT — modules/hosts/desktop/default.nix
#
# This is a flake-parts module. It registers the nixos-desktop machine into
# flake.nixosConfigurations by collecting all staged feature modules and
# combining them with hardware-specific overrides.
#
# Compare to current split:
#   flake.nix    — registered the machine + threaded hostName via extraSpecialArgs
#   hosts/desktop/configuration.nix — host overrides (GPU, SSH keys, gaming)
#
# Now everything for this machine is in one place.

{ inputs, config, withSystem, ... }:

{
  flake.nixosConfigurations.nixos-desktop = withSystem "x86_64-linux" (
    { pkgs, ... }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit pkgs;
      modules =
        # 1. Hardware config (auto-generated, machine-specific)
        [ ./hardware-configuration.nix ]

        # 2. All NixOS feature modules staged by other flake-parts modules
        ++ builtins.attrValues config.flake.modules.nixos

        # 3. Host-specific overrides and home-manager wiring
        ++ [{
          networking.hostName = "nixos-desktop";

          # SSH authorized keys for this machine
          users.users.elias.openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJrmlWbyrXyqEI8nP/N31d1yfT314rk3Jr7DS47f6Q27 desktop ssh"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILDeEc67/KYXhCTX4rlOxRektzY3VneGcf784a8U5gUB research project elias desktop"
          ];

          # Desktop GPU: NVIDIA open drivers + RTL8812AU wifi dongle
          services.xserver.videoDrivers = [ "nvidia" ];
          hardware.nvidia.open = true;
          boot.extraModulePackages = with pkgs.linuxPackages; [ rtl8812au ];
          boot.kernelModules = [ "8812au" ];

          # Enable gaming on desktop (module defined in modules/gaming.nix)
          custom.gaming.enable = true;
          custom.gaming.tvOutput = "HDMI-A-1";

          # Host-specific monitor symlink (replaces extraSpecialArgs hostName hack)
          # home.nix used hostName to pick monitors-<hostName>.conf.
          # In the dendritic pattern this is expressed directly here.
          home-manager.users.elias = {
            imports = builtins.attrValues config.flake.modules.homeManager;
            home.file.".config/hypr/monitors.conf" = {
              source = config.lib.file.mkOutOfStoreSymlink
                "/home/elias/nixos-dotfiles/config/hypr/monitors-nixos-desktop.conf";
            };
          };
        }];
    }
  );
}
