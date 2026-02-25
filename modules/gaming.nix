{ config, lib, pkgs, ... }:

let
  cfg = config.custom.gaming;

  game-console = pkgs.writeShellScriptBin "game-console" ''

    hyprctl keyword monitor "HDMI-A-1,1920x1080@60,2560,1"
    sleep 1
    hyprctl keyword workspace "10, monitor:HDMI-A-1, default:true"
    hyprctl keyword windowrulev2 "workspace 10, class:^(.gamescope-wrapped)$"
    hyprctl keyword windowrulev2 "fullscreen, class:^(.gamescope-wrapped)$"
    hyprctl keyword windowrulev2 "monitor HDMI-A-1, class:^(.gamescope-wrapped)$"
    TV_WIDTH=1920
    TV_HEIGHT=1080
    ${pkgs.gamescope}/bin/gamescope \
      -W "$TV_WIDTH" -H "$TV_HEIGHT" \
      -w  "$TV_WIDTH" -h "$TV_HEIGHT" \
      -e \
      --prefer-output ${cfg.tvOutput} \
      --backend sdl \
      -- steam -gamepadui \
      || true
      hyprctl keyword monitor "HDMI-A-1,disable"
  '';

  steamos-session-select = pkgs.writeShellScriptBin "steamos-session-select" ''
    steam -shutdown
    sleep 2
    pkill gamescope 2>/dev/null || true
  '';

in
{
  options.custom.gaming = {
    enable = lib.mkEnableOption "kid-friendly gaming setup";
    tvOutput = lib.mkOption
      {
        type = lib.types.str;
        default = "HDMI-A-1";
        description = "Console Output";
      };
  };

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      gamescopeSession.enable = true;
    };

    programs.gamescope = {
      enable = true;
      capSysNice = true;
    };

    hardware.steam-hardware.enable = true;
    hardware.xone.enable = true;
    hardware.xpadneo.enable = true;
    hardware.graphics.enable32Bit = true;

    boot.kernelParams = [ "nvidia-drm.modeset=1" ];
    hardware.nvidia.modesetting.enable = true;

    environment.systemPackages = with pkgs; [
      retroarch
      duckstation
      wlr-randr
      game-console
      steamos-session-select
    ];
  };
}
