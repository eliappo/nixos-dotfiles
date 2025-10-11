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

  users = {
    groups.uinput = { };
    users.elias = {
      isNormalUser = true;
      extraGroups = [ "wheel" "input" "uinput" ];
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
    alacritty
    wget
    wl-clipboard # Changed from xclip for Wayland
    waybar # Status bar for Hyprland
    brave
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "25.05";
}
