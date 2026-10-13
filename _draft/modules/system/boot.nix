# DRAFT — modules/system/boot.nix
#
# Bootloader configuration shared by all hosts.
# Host-specific kernel modules (e.g. rtl8812au) stay in the host module.

{ ... }:

{
  flake.modules.nixos.boot = {
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      useOSProber = true;
    };
  };
}
