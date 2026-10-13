# DRAFT — modules/desktop/kanata.nix
#
# Kanata keyboard remapping — NixOS side (uinput groups are in system/users.nix)
# and home-manager side (the two systemd user services).
#
# Previously: home.nix lines 465-500 (services only, packages mixed into home.packages)
# The uinput kernel module and group were in common.nix (now system/users.nix).
# Kanata package install is added here alongside its services.

{ pkgs, ... }:

let
  dotfiles = "/home/elias/nixos-dotfiles/config";
in
{
  # NixOS side: nothing needed beyond uinput (handled in system/users.nix)
  # Left here as a placeholder if e.g. a udev rule specific to kanata is needed.
  flake.modules.nixos.kanata = { };

  flake.modules.homeManager.kanata = {
    home.packages = [ pkgs.kanata ];

    systemd.user.services.kanata-builtin = {
      Unit = {
        Description = "Kanata keyboard layout for builtin and regular keyboards";
        Documentation = "https://github.com/jtroo/kanata";
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.kanata}/bin/kanata --cfg ${dotfiles}/kanata/kanata-builtin.kbd.lisp";
        Restart = "on-failure";
        RestartSec = "5s";
        StartLimitBurst = 3;
        StartLimitIntervalSec = "60s";
      };
      Install.WantedBy = [ "default.target" ];
    };

    systemd.user.services.kanata-kinesis = {
      Unit = {
        Description = "Kanata keyboard layout for the kinesis keyboard";
        Documentation = "https://github.com/jtroo/kanata";
        ConditionPathExists = "/dev/input/by-path/pci-0000:00:14.0-usbv2-0:6:1.1-event-kbd";
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.kanata}/bin/kanata --cfg ${dotfiles}/kanata/kanata-kinesis.kbd.lisp";
        Restart = "on-failure";
        RestartSec = "5s";
        StartLimitBurst = 3;
        StartLimitIntervalSec = "60s";
      };
      Install.WantedBy = [ "default.target" ];
    };
  };
}
