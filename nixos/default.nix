# Collects all shared NixOS modules. Imported by every host.
# `inputs` is available here because host modules pass specialArgs = { inherit inputs; }.
{ inputs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.stylix.nixosModules.stylix

    ./core.nix
    ./boot.nix
    ./networking.nix
    ./users.nix
    ./hardware.nix
    ./virtualization.nix
    ./desktop.nix
    ./theming.nix
    ./packages.nix
    ./gaming.nix
  ];
}
