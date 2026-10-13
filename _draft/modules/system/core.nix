# DRAFT — modules/system/core.nix
#
# Baseline NixOS settings that apply to every machine.
# Previously spread across modules/common.nix.
#
# Contains: timezone, nixpkgs policy, flake feature flags, stateVersion,
#           man pages, nix-ld, build tools, and system packages.

{ inputs, pkgs, ... }:

{
  flake.modules.nixos.core = {
    nixpkgs.config.allowUnfree = true;
    nixpkgs.overlays = [ inputs.claude-code.overlays.default ];

    time.timeZone = "Europe/Amsterdam";

    programs.nix-ld.enable = true;
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    documentation.man.generateCaches = true;

    # uinput kernel module (needed by kanata)
    boot.kernelModules = [ "uinput" ];
    users.groups.uinput = { };
    services.udev.extraRules = ''
      KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
    '';

    # Build toolchain available system-wide
    environment.systemPackages = with pkgs; [
      vim
      wget
      man-pages
      gcc
      clang
      cmake
      gnumake
      bear
      bat
      wl-clipboard
      brightnessctl
      pamixer
      vagrant
      openconnect
      bottles
      wine
      winetricks
      xorg.libxkbfile
      brave
      claude-code
    ];

    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];

    system.stateVersion = "25.05";
  };
}
