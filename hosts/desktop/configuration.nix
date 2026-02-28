{ config, lib, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "nixos-desktop";

  users.users.elias = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJrmlWbyrXyqEI8nP/N31d1yfT314rk3Jr7DS47f6Q27 desktop ssh"
    ];
  };

  # Desktop-specific GPU config (adjust to your actual GPU)
  services.xserver.videoDrivers = [ "nvidia" ]; # or "amdgpu"
  hardware.nvidia.open = true; # uncomment if nvidia

  # Gaming module ON
  custom.gaming = {
    enable = true;
    tvOutput = "HDMI-A-1";
  };
}
