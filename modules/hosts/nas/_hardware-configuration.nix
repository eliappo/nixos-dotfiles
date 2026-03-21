# Hardware configuration for nixos-nas.
#
# fileSystems and swapDevices are intentionally absent — disko generates them
# from disk-config.nix.  After install you may regenerate with:
#   sudo nixos-generate-config --show-hardware-config
# and add any missing kernel modules here.

{ modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  nixpkgs.hostPlatform = "x86_64-linux";
}
