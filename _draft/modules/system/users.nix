# DRAFT — modules/system/users.nix
#
# User accounts, groups, and home-manager integration.
# The home-manager module itself is wired in here so it does not
# need to be manually listed in flake.nix.
#
# NOTE: home-manager.users.elias.imports is intentionally left empty here.
# Each host module sets it to: builtins.attrValues config.flake.modules.homeManager
# This is the host's job — it decides which home-manager modules to include.

{ inputs, ... }:

{
  flake.modules.nixos.users = {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    users.users.elias = {
      isNormalUser = true;
      extraGroups = [ "wheel" "input" "uinput" "docker" "video" "dialout" "vboxusers" ];
      packages = [ ]; # prefer home.packages in home-manager modules
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";
      # users.elias.imports is set per-host to builtins.attrValues config.flake.modules.homeManager
    };
  };
}
