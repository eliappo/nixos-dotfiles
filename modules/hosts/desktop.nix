# flake-parts module — registers nixosConfigurations.nixos-desktop
{ inputs, ... }:

{
  flake.nixosConfigurations.nixos-desktop = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    # specialArgs makes `inputs` available inside every NixOS module via { inputs, ... }
    specialArgs = { inherit inputs; };
    modules = [
      ../../hosts/desktop/hardware-configuration.nix
      ../../nixos/default.nix

      ({ pkgs, ... }: {
        networking.hostName = "nixos-desktop";

        # GPU
        services.xserver.videoDrivers = [ "nvidia" ];
        hardware.nvidia.open = true;

        # RTL8812AU USB wifi dongle
        boot.extraModulePackages = with pkgs.linuxPackages; [ rtl8812au ];
        boot.kernelModules = [ "8812au" ];

        # SSH authorized keys
        users.users.elias.openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJrmlWbyrXyqEI8nP/N31d1yfT314rk3Jr7DS47f6Q27 desktop ssh"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILDeEc67/KYXhCTX4rlOxRektzY3VneGcf784a8U5gUB research project elias desktop"
        ];

        # Gaming: full gamescope/TV console setup
        custom.gaming.enable = true;
        custom.gaming.tvOutput = "HDMI-A-1";

        # Home-manager wiring — hostName picks the correct monitors.conf symlink
        home-manager.extraSpecialArgs = { hostName = "nixos-desktop"; };
        home-manager.users.elias.imports = [ ../../home/default.nix ];
      })
    ];
  };
}
