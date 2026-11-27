{ inputs, pkgs, ... }:

{
  #Allow propietary garbage as Tony says
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [
    inputs.claude-code.overlays.default
    (final: prev: {
      niri = inputs.niri.packages.${prev.system}.niri;
      raddebugger = inputs.raddbg.legacyPackages.${prev.system}.raddebugger;
      # zotero-pkg's binary isn't patchelf'd: it runs via nix-ld on the *system* glibc,
      # so its runtime libs must come from our nixpkgs (not unstable) or glibc mismatches.
      # zotero-bin.nix uses unstable's top-level xorg names (libX11, …) → merge prev.xorg in.
      zotero =
        let
          data = (builtins.fromJSON (builtins.readFile "${inputs.zotero}/nix.json")).release.${prev.system};
        in
        prev.callPackage "${inputs.zotero}/zotero-bin.nix" {
          pkgs = prev // prev.xorg;
          binName = "zotero";
          inherit (data) version url;
          sha256 = data.hash;
        };
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
    raddebugger
  ];

  programs.nix-ld.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Man database
  documentation.man.generateCaches = false;
  services.udisks2.enable = true;

  system.stateVersion = "25.05";
}
