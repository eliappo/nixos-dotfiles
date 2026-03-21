{ pkgs, ... }:

{
  programs.mpv.enable = true;
  programs.zathura.enable = true;

  home.packages = with pkgs; [
    (obs-studio.override {
      cudaSupport = true;
    })

    freecad
    (pkgs.prusa-slicer.overrideAttrs (old: {
      nativeBuildInputs = old.nativeBuildInputs or [ ] ++ [ pkgs.makeWrapper ];
      postInstall = (old.postInstall or "") + ''
        wrapProgram $out/bin/prusa-slicer \
          --set __GLX_VENDOR_LIBRARY_NAME mesa \
          --set MESA_LOADER_DRIVER_OVERRIDE zink \
          --set GALLIUM_DRIVER zink
      '';
    }))
    graphviz
    fritzing
  ];
}
