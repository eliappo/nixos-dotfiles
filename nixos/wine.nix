{ pkgs, ... }:

{
  #For running windows apps
  environment.systemPackages = with pkgs; [
    bottles
    wine
    winetricks
    xorg.libxkbfile
  ];
}
