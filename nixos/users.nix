{ ... }:

{
  users = {
    groups.uinput = { };
    users.elias = {
      isNormalUser = true;
      extraGroups = [ "wheel" "input" "uinput" "docker" "video" "dialout" "vboxusers" ];
      packages = [ ]; # prefer home.packages in home-manager modules
    };
  };

  boot.kernelModules = [ "uinput" ];

  services.udev.extraRules = ''
    KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
  '';

  # Home-manager global settings shared by all hosts.
  # Per-host: extraSpecialArgs and users.elias.imports are set in the host module.
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
  };
}
