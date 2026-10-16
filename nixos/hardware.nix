{ config, lib, ... }:

let
  # Audio backend is per-host: the desktop drives an Arturia MiniFuse 4 over
  # PipeWire (+ JACK, low-latency profile); the laptop stays on PulseAudio.
  isDesktop = config.networking.hostName == "nixos-desktop";
in
{
  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true; # Power on Bluetooth adapter on boot
  };

  # services.blueman.enable = true; # Blueman GUI for easy pairing

  # Brightness control
  programs.light.enable = true;

  security.rtkit.enable = true;

  # Laptop: PulseAudio.
  services.pulseaudio.enable = !isDesktop;

  # Audio backend is explicit per-host. pipewire.enable must be set both ways:
  # the graphical-desktop module (pulled in by Hyprland/Niri) defaults it to
  # true, so the laptop needs an explicit `false` to stay on PulseAudio and
  # avoid a pipewire+pulseaudio conflict.
  services.pipewire =
    if isDesktop then {
      # Desktop: PipeWire with MiniFuse 4 low-latency profile.
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;

      # Low-latency config for Arturia MiniFuse 4
      extraConfig.pipewire."92-minifuse-low-latency" = {
        context.properties = {
          default.clock.rate = 48000;
          default.clock.quantum = 64;
          default.clock.min-quantum = 64;
          default.clock.max-quantum = 512;
        };
      };
    } else {
      enable = false;
    };
}
