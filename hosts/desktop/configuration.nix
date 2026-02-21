{ config, lib, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "nixos-desktop";

  # Desktop-specific GPU config (adjust to your actual GPU)
  services.xserver.videoDrivers = [ "nvidia" ]; # or "amdgpu"
  hardware.nvidia.open = true;  # uncomment if nvidia

  # Gaming module ON
  custom.gaming.enable = true;
}
