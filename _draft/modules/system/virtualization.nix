# DRAFT — modules/system/virtualization.nix

{ ... }:

{
  flake.modules.nixos.virtualization = {
    virtualisation.docker.enable = true;
    virtualisation.virtualbox.host.enable = true;
  };
}
