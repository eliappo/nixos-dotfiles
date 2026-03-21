{ pkgs, ... }:

let
  myscripts = import ../scripts.nix { inherit pkgs; };
in
{
  home.packages = with pkgs; [
    myscripts.pintos-symlink #Pintos related scripts for OSandC course.
    myscripts.screen-shot-drag #Dragged screen shot to clipboard.

    obsidian #Note Tool
    pastel
    astroterm
    localsend

    ## Utils
    unzip
    unrar
    p7zip
    btop
    rclone

    ## System appearance
    hyprpaper
    hyprpicker
    nixpkgs-fmt
    rofi
    kanata
    font-awesome
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    papirus-icon-theme
    glow #Terminal markdown render

    # Muggler text app
    libreoffice
  ];
}
