{ ... }:
{
  services.udev.extraRules = ''
    # Daisy Seed DFU
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE="0666", GROUP="plugdev"
    # ST-Link Mini v3
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3754", MODE:="0666", SYMLINK+="stlinkv3_%n"
  '';
  users.users.elias.extraGroups = [ "plugdev" ];
}
