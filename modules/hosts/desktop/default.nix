# flake-parts module — registers nixosConfigurations.nixos-desktop
{ inputs, ... }:

{
  flake.nixosConfigurations.nixos-desktop = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      ./_hardware-configuration.nix
      ../../../nixos/default.nix

      {
        networking.hostName = "nixos-desktop";

        # GPU and wifi dongle via declarative options (nixos/nvidia.nix, nixos/rtl8812au.nix)
        custom.nvidia.enable = true;
        custom.rtl8812au.enable = true;

        # Gaming: full gamescope/TV console setup
        custom.gaming.enable = true;
        custom.gaming.tvOutput = "HDMI-A-1";

        custom.syncthing.enable = true;

        # SSH authorized keys
        users.users.elias.openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJrmlWbyrXyqEI8nP/N31d1yfT314rk3Jr7DS47f6Q27 desktop ssh"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILDeEc67/KYXhCTX4rlOxRektzY3VneGcf784a8U5gUB research project elias desktop"
        ];

        # home/desktop.nix reads networking.hostName via osConfig — no extraSpecialArgs needed
        home-manager.users.elias.imports = [ ../../../home/default.nix ];
      }
    ];
  };
}
