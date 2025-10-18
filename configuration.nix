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
    "bolig37" = {
      psk = secrets.wifiPasswords."bolig37";
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



  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true; # Power on Bluetooth adapter on boot
  };

  # services.blueman.enable = true; # Blueman GUI for easy pairing
  services.displayManager.ly.enable = true;
  # Enable Hyprland
  programs.hyprland.enable = true;

  # XDG portal for screen sharing, file pickers, etc.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  virtualisation.docker.enable = true;

  # Brightness control
  programs.light.enable = true;

  # Sound with PipeWire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users = {
    groups.uinput = { };
    users.elias = {
      isNormalUser = true;
      extraGroups = [ "wheel" "input" "uinput" "docker" "video" ];
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
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-volman
      thunar-archive-plugin
    ];
  };

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
    brightnessctl
    pamixer
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  # stylix color scheme. Find what you like anddd put here!
  #search "Ricing linux has never been easier | NixOS + stylix" on youtube.
  stylix = {
    enable = true;
    image = /home/elias/Wallpapers/uwp4293631.png;
    #base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
    polarity = "dark";
    fonts = {
      sizes = {
        terminal = 18;
        applications = 14;
        desktop = 16;
        popups = 18;
      };
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font Propo";
      };
      sansSerif = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font Propo";
      };
      serif = config.stylix.fonts.sansSerif;
    };
    opacity = {
      terminal = 0.85;
      applications = 1.0;
      desktop = 1.0;
      popups = 0.95;
    };
    cursor = {
      package = pkgs.vanilla-dmz;
      name = "Vanilla-DMZ";
      size = 24;
    };
    #Possibly cursor settings here also.
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "25.05";
}
