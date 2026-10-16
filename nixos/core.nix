{ inputs, pkgs, ... }:

{
  #Allow propietary garbage as Tony says
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [
    inputs.claude-code.overlays.default
    (final: prev: {
      niri = inputs.niri.packages.${prev.system}.niri;
    })
  ];

  nix.settings.trusted-users = [ "root" "elias" ];

  time.timeZone = "Europe/Amsterdam";

  environment.systemPackages = with pkgs; [
    vim
    wget
    man-pages
    bat #cool cat with sexy higlights
    coreutils #Some core ulilities?
    claude-code
  ];

  programs.nix-ld.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Man database
  documentation.man.generateCaches = true;
  services.udisks2.enable = true;

  system.stateVersion = "25.05";
}
