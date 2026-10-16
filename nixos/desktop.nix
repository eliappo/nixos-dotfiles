{ config, lib, pkgs, ... }:

let
  cfg = config.custom.niri;
in
{
  options.custom.niri.enable =
    lib.mkEnableOption "Niri compositor (+ xwayland-satellite for X11 apps)";

  config = {
    environment.systemPackages = with pkgs; [
      wl-clipboard # Changed from xclip for Wayland
      brave #A browser that claimss to protect you
      brightnessctl
      pamixer
    ] ++ lib.optionals cfg.enable [
      qpwgraph # PipeWire graph/routing tool for MiniFuse 4 channel routing

      # Niri has no built-in XWayland. Since niri 25.08 it auto-spawns
      # xwayland-satellite (creates the X11 socket, exports $DISPLAY on demand)
      # as long as the binary (>=0.7) is on PATH. Required for X11 apps/games
      # under Niri, e.g. Steam.
      xwayland-satellite
    ];

    services.displayManager.ly.enable = true;

    # Hyprland on every desktop/laptop host; Niri opt-in per host.
    programs.hyprland.enable = true;
    programs.niri.enable = cfg.enable;

    # XDG portal for screen sharing, file pickers, etc.
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      config = {
        common.default = [ "gtk" ];
        Hyprland.default = [ "hyprland" "gtk" ];
      } // lib.optionalAttrs cfg.enable {
        niri.default = [ "gtk" ];
      };
    };

    programs.firefox.enable = true;
    programs.thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-volman
        thunar-archive-plugin
      ];
    };
  };
}
