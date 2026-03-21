{ ... }:

{
  services.pulseaudio.enable = true;

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true; # Power on Bluetooth adapter on boot
  };

  # services.blueman.enable = true; # Blueman GUI for easy pairing

  # Brightness control
  programs.light.enable = true;

  # Sound with PipeWire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = false;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
