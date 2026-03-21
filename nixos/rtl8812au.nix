{ config, lib, pkgs, ... }:

{
  options.custom.rtl8812au.enable = lib.mkEnableOption "RTL8812AU USB wifi dongle";

  config = lib.mkIf config.custom.rtl8812au.enable {
    boot.extraModulePackages = with pkgs.linuxPackages; [ rtl8812au ];
    boot.kernelModules = [ "8812au" ];
  };
}
