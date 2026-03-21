{ config, pkgs, ... }:

{
  # stylix color scheme. Find what you like anddd put here!
  #search "Ricing linux has never been easier | NixOS + stylix" on youtube.
  stylix = {
    enable = true;
    image = ../Wallpapers/uwp4293631.png;
    #base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
    polarity = "dark";
    fonts = {
      sizes = {
        terminal = 18;
        applications = 14;
        desktop = 16;
        popups = 18;
      };
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font Mono";
      };
      sansSerif = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font Mono";
      };
      serif = config.stylix.fonts.sansSerif;
    };
    opacity = {
      terminal = 0.85;
      applications = 1.0;
      desktop = 1.0;
      popups = 0.95;
    };
    cursor = {
      package = pkgs.vanilla-dmz;
      name = "Vanilla-DMZ";
      size = 24;
    };
    #Possibly cursor settings here also.
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];
}
