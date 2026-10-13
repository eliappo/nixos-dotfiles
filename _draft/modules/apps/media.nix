# DRAFT — modules/apps/media.nix
#
# Media consumption and production tools.
# Previously home.nix lines 502-503, 532-614 (mixed into a large packages list).

{ pkgs, ... }:

{
  flake.modules.homeManager.media = {
    programs.mpv.enable = true;
    programs.zathura.enable = true;

    home.packages = with pkgs; [
      (obs-studio.override { cudaSupport = true; })

      # CAD / hardware design
      freecad
      (prusa-slicer.overrideAttrs (old: {
        nativeBuildInputs = old.nativeBuildInputs or [ ] ++ [ makeWrapper ];
        postInstall = (old.postInstall or "") + ''
          wrapProgram $out/bin/prusa-slicer \
            --set __GLX_VENDOR_LIBRARY_NAME mesa \
            --set MESA_LOADER_DRIVER_OVERRIDE zink \
            --set GALLIUM_DRIVER zink
        '';
      }))
      fritzing
      graphviz
    ];
  };
}
