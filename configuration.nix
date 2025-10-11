{ config, lib, pkgs, ... }:

let
  secrets = import /home/elias/secrets.nix; #Place your secrets outside of the flake-directory because git.
in
{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos-virgin";
  networking.wireless.enable = true;

  networking.wireless.networks = {
    "Nr. 4 5GHz" = {
      psk = secrets.wifiPasswords."Nr. 4 5GHz";
    };
    "ITU-Guest" = { };
    eduroam = {
      auth = ''
        key_mgmt=WPA-EAP
        eap=PWD
        identity="${secrets.wifiPasswords.eduroam.identity}"
        password="${secrets.wifiPasswords.eduroam.password}"
      '';
    };
  };

  time.timeZone = "Europe/Amsterdam";

  services.displayManager.ly.enable = true;
  # Enable Hyprland
  programs.hyprland.enable = true;

  # XDG portal for screen sharing, file pickers, etc.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  virtualisation.docker.enable = true;

  users = {
    groups.uinput = { };
    users.elias = {
      isNormalUser = true;
      extraGroups = [ "wheel" "input" "uinput" "docker" ];
      packages = with pkgs; [
        tree
      ];
    };
  };

  boot.kernelModules = [ "uinput" ];

  services.udev.extraRules = ''
    KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
  '';

  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    vim
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
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  # stylix color scheme. Find what you like anddd put here!
  #search "Ricing linux has never been easier | NixOS + stylix" on youtube.
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
    polarity = "dark";
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font Mono";
      };
      sansSerif = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font Mono";
      };
      serif = config.stylix.fonts.sansSerif;
    };
    opacity = {
      terminal = 0.9;
      applications = 1.0;
      desktop = 1.0;
      popups = 0.95;
    };
    #Possibly cursor settings here also.
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "25.05";
}
