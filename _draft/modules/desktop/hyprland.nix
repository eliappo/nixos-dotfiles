# DRAFT — modules/desktop/hyprland.nix
#
# THE KEY EXAMPLE OF THE DENDRITIC PATTERN.
#
# Previously:
#   modules/common.nix line 36  → programs.hyprland.enable = true
#   home.nix lines 458-463      → xdg.configFile."hypr" symlink
#   home.nix lines 44-45        → monitors.conf symlink (host-specific, stays in host module)
#
# Now both the NixOS side and the home-manager side live together.
# The relationship between "enable Hyprland system-wide" and "link the config files"
# is immediately visible in one file.

{ pkgs, ... }:

{
  # NixOS side: enable the compositor and XDG portal
  flake.modules.nixos.hyprland = {
    programs.hyprland.enable = true;

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };

    services.displayManager.ly.enable = true;
  };

  # Home-manager side: link config files and install helper tools
  # monitors.conf is intentionally NOT here — it is host-specific and is
  # set directly in each host module (modules/hosts/desktop/default.nix).
  flake.modules.homeManager.hyprland = { config, ... }: {
    xdg.configFile."hypr" = {
      source = config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/nixos-dotfiles/config/hypr";
      recursive = true;
    };

    home.packages = with pkgs; [
      hyprpaper
      hyprpicker
    ];
  };
}
