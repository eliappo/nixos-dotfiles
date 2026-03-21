{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vim
    man-pages
    #    alacritty
    wget
    wl-clipboard # Changed from xclip for Wayland
    #    waybar # Status bar for Hyprland
    brave #A browser that claimss to protect you
    bear #Create compile-commands.json for clangd lsp
    cmake
    gnumake
    gcc #good ol' C compiler for serious programs
    clang #C compiler
    coreutils #Some core ulilities?
    bat #cool cat with sexy higlights
    brightnessctl
    pamixer
    vagrant #Virtualization tool
    openconnect #open source vpn tunnel
    claude-code

    ## Networking
    # zerotierone

    #For running windows apps
    bottles
    wine
    winetricks
    xorg.libxkbfile
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];
}
