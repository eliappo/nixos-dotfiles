# DRAFT — modules/desktop/stylix.nix
#
# Stylix theming — NixOS module + home-manager targets in one file.
# Previously split: NixOS config in common.nix lines 159-195,
#                   HM target override (rofi) in home.nix line 202.

{ inputs, pkgs, ... }:

{
  flake.modules.nixos.stylix = {
    imports = [ inputs.stylix.nixosModules.stylix ];

    stylix = {
      enable = true;
      image = ../../../Wallpapers/uwp4293631.png;
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
    };
  };

  # Disable stylix for rofi — it has its own theme
  flake.modules.homeManager.stylix = {
    stylix.targets.rofi.enable = false;
  };
}
