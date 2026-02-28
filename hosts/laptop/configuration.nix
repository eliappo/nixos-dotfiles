{ config, lib, pkgs, ... }:

let
  secrets = import /home/elias/secrets.nix;
in
{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "nixos-virgin";

  # Laptop-specific: nvidia
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = true;
  hardware.nvidia.powerManagement.enable = true;

  # Steam on laptop (without the full gaming/gamescope setup)
  programs.steam.enable = true;
  hardware.graphics.enable32Bit = true;

  # Gaming module OFF on laptop
  custom.gaming.enable = false;
}
