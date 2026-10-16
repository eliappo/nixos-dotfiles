# osConfig gives read access to the NixOS configuration from within a HM module.
# Used here to read networking.hostName without needing extraSpecialArgs.
{ config, lib, pkgs, osConfig, ... }:

let
  dotfiles = "${config.home.homeDirectory}/nixos-dotfiles/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
  isDesktop = osConfig.networking.hostName == "nixos-desktop";
in
{
  # Host-specific monitor config — reads hostName directly from NixOS config
  home.file.".config/hypr/monitors.conf".source =
    create_symlink "${dotfiles}/hypr/monitors-${osConfig.networking.hostName}.conf";

  # Symlink all application config directories out-of-store so edits take effect immediately
  xdg.configFile = builtins.mapAttrs
    (name: subpath: {
      source = create_symlink "${dotfiles}/${subpath}";
      recursive = true;
    })
    ({
      qtile = "qtile";
      nvim = "nvim";
      rofi = "rofi";
      kanata = "kanata";
      hypr = "hypr";
    } // lib.optionalAttrs osConfig.custom.niri.enable {
      niri = "niri";
    });

  systemd.user.services = {
    kanata-builtin = {
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
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  }
  # The Kinesis Advantage360 lives on the desktop only.
  // lib.optionalAttrs isDesktop {
    kanata-kinesis = {
      Unit = {
        Description = "Kanata keyboard layout for the kinesis keyboard";
        Documentation = "https://github.com/jtroo/kanata";
        ConditionPathExists = "/dev/input/by-id/usb-Kinesis_Kinesis_Adv360_360555127546-if01-event-kbd";
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.kanata}/bin/kanata --cfg ${dotfiles}/kanata/kanata-kinesis.kbd.lisp";
        Restart = "on-failure";
        RestartSec = "5s";
        StartLimitBurst = 3;
        StartLimitIntervalSec = "60s";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
