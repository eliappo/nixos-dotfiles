# DRAFT — modules/apps/tools.nix
#
# Productivity and utility apps that don't fit a more specific category.
# Previously mixed into the large home.packages list in home.nix.

{ pkgs, ... }:

{
  flake.modules.homeManager.tools = {
    home.packages = with pkgs; [
      obsidian
      localsend
      libreoffice
      btop
      rclone
      unzip
      unrar
      p7zip
      glow       # terminal markdown renderer
      pastel     # color picker / palette tool
      astroterm
      slurp      # screen region selector (used by screenshot script)
      grim       # screenshot tool
      font-awesome
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      papirus-icon-theme
    ];

    gtk = {
      enable = true;
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };
    };

    fonts.fontconfig.enable = true;
  };
}
