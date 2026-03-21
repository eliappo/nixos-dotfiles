{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    wl-clipboard # Changed from xclip for Wayland
    brave #A browser that claimss to protect you
    brightnessctl
    pamixer
  ];

  services.displayManager.ly.enable = true;

  # Enable Hyprland
  programs.hyprland.enable = true;

  # XDG portal for screen sharing, file pickers, etc.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
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
