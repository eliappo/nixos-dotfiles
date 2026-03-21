{ config, lib, ... }:

let
  cfg = config.custom.syncthing;
in
{
  options.custom.syncthing = {
    enable = lib.mkEnableOption "Syncthing continuous file synchronisation";

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/home/elias/sync";
      description = "Root directory where synchronised folders are stored.";
    };

    guiPort = lib.mkOption {
      type = lib.types.port;
      default = 8384;
      description = "Port for the Syncthing web UI.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      # Run as the regular user so file ownership is correct
      user = "elias";
      group = "users";
      dataDir = cfg.dataDir;
      # Listen on all interfaces so the web UI is reachable over Tailscale.
      # Protected by Syncthing's own authentication.
      guiAddress = "0.0.0.0:${toString cfg.guiPort}";
      # Opens 22000/TCP (sync) and 21027/UDP (discovery)
      openDefaultPorts = true;
    };

    networking.firewall.allowedTCPPorts = [ cfg.guiPort ];
  };
}
