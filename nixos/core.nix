{ inputs, ... }:

{
  #Allow propietary garbage as Tony says
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [ inputs.claude-code.overlays.default ];

  time.timeZone = "Europe/Amsterdam";

  programs.nix-ld.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Man database
  documentation.man.generateCaches = true;

  system.stateVersion = "25.05";
}
