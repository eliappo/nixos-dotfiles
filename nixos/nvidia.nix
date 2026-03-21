{ config, lib, ... }:

let
  cfg = config.custom.nvidia;
in
{
  options.custom.nvidia = {
    enable = lib.mkEnableOption "NVIDIA GPU setup";
    powerManagement = lib.mkEnableOption "NVIDIA power management (for laptops)";
  };

  config = lib.mkIf cfg.enable {
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.nvidia.open = true;
    hardware.nvidia.powerManagement.enable = cfg.powerManagement;
  };
}
