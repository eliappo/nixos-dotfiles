{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    wl-clipboard # Changed from xclip for Wayland
    brave #A browser that claimss to protect you
    brightnessctl
    pamixer
    qpwgraph # PipeWire graph/routing tool for MiniFuse 4 channel routing

    # Niri has no built-in XWayland. Since niri 25.08 it auto-spawns xwayland-satellite
    # (creates the X11 socket, exports $DISPLAY on demand) as long as the binary (>=0.7) is
    # on PATH. Required for X11 apps/games under Niri, e.g. Steam. Inert under Hyprland,
    # which bundles its own XWayland and ignores it.
    xwayland-satellite
  ];

  services.displayManager.ly.enable = true;

  programs.hyprland.enable = true;
  programs.niri.enable = true;

  # XDG portal for screen sharing, file pickers, etc.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config = {
      common.default = [ "gtk" ];
      niri.default = [ "gtk" ];
      Hyprland.default = [ "hyprland" "gtk" ];
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
}
