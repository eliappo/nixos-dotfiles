{ config, lib, pkgs, ... }:

let
  cfg = config.custom.git-server;
in
{
  options.custom.git-server = {
    enable = lib.mkEnableOption "Bare git repository hosting over SSH";

    repoDir = lib.mkOption {
      type = lib.types.str;
      default = "/srv/git";
      description = ''
        Directory where bare git repositories live.

        To create a new repo (on the NAS or via SSH):
          git init --bare /srv/git/myproject.git

        To clone from another machine (LAN or ZeroTier):
          git clone elias@nixos-nas:/srv/git/myproject.git
          git clone elias@<zerotier-ip>:/srv/git/myproject.git

        To add as a remote on an existing repo:
          git remote add nas elias@nixos-nas:/srv/git/myproject.git
          git push nas main
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.git ];

    systemd.tmpfiles.rules = [
      "d ${cfg.repoDir} 0755 elias users -"
    ];
  };
}
