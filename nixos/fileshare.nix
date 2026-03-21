{ config, lib, pkgs, ... }:

let
  cfg = config.custom.fileshare;
in
{
  options.custom.fileshare = {
    enable = lib.mkEnableOption "Public HTTPS file sharing and authenticated web file manager";

    domain = lib.mkOption {
      type = lib.types.str;
      description = ''
        Public domain pointing to this machine's IP (e.g. "files.yourdomain.com").
        Caddy automatically obtains and renews a Let's Encrypt certificate.
        Requires ports 80 and 443 forwarded on the router to this machine.
      '';
    };

    publicDir = lib.mkOption {
      type = lib.types.str;
      default = "/srv/public";
      description = ''
        Publicly readable directory served over HTTPS with directory listing.
        No authentication — anything placed here is accessible to the internet.
        Ideal for sharing a file with a friend or providing a download URL
        (e.g. a custom ISO URL for DigitalOcean Spaces / custom images).

        Upload via:
          scp myfile.iso elias@nixos-nas:/srv/public/
          rsync -av myfile.iso elias@nixos-nas:/srv/public/
      '';
    };

    filesDir = lib.mkOption {
      type = lib.types.str;
      default = "/srv/files";
      description = ''
        Private directory managed by the Filebrowser web UI.
        Accessible only on LAN or over ZeroTier — not exposed to the internet.
      '';
    };

    filebrowserPort = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "Port for the Filebrowser web UI (LAN / ZeroTier access only).";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d ${cfg.publicDir} 0775 elias users -"
      "d ${cfg.filesDir}  0775 elias users -"
    ];

    # Caddy: serves publicDir over HTTPS with automatic Let's Encrypt cert.
    # Caddy handles HTTP→HTTPS redirect and certificate renewal automatically.
    services.caddy = {
      enable = true;
      virtualHosts.${cfg.domain}.extraConfig = ''
        root * ${cfg.publicDir}
        file_server browse
        encode gzip
      '';
    };

    # Filebrowser: authenticated drag-and-drop web UI for /srv/files.
    # Reachable at http://nixos-nas:8080 (LAN) or http://<zerotier-ip>:8080 (remote).
    # Default credentials: admin / admin — change immediately on first login.
    systemd.services.filebrowser = {
      description = "Filebrowser web file manager";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        ExecStart = lib.escapeShellArgs [
          "${pkgs.filebrowser}/bin/filebrowser"
          "--address" "0.0.0.0"
          "--port" (toString cfg.filebrowserPort)
          "--root" cfg.filesDir
          "--database" "/var/lib/filebrowser/filebrowser.db"
        ];
        User = "elias";
        StateDirectory = "filebrowser";
        Restart = "on-failure";
      };
    };

    # 80 and 443 for Caddy (HTTPS public); filebrowserPort for LAN/ZeroTier access.
    networking.firewall.allowedTCPPorts = [ 80 443 cfg.filebrowserPort ];
  };
}
