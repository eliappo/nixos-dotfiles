{ pkgs, ... }:

{
  stylix.targets.rofi.enable = false;

  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };
}
