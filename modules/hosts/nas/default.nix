# flake-parts module — registers nixosConfigurations.nixos-nas
{ inputs, ... }:

{
  flake.nixosConfigurations.nixos-nas = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      ./_hardware-configuration.nix
      ./_disk-config.nix
      inputs.disko.nixosModules.disko
      ../../../nixos/server.nix

      ({ pkgs, ... }: {
        networking.hostName = "nixos-nas";

        # Keep running with lid closed
        services.logind.lidSwitch = "ignore";
        services.logind.lidSwitchExternalPower = "ignore";

        networking.interfaces.wlp4s0.ipv4.addresses = [{
          address = "192.168.10.101";
          prefixLength = 24;
        }];
        networking.defaultGateway = "192.168.10.1";
        networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];

        users.users.elias = {
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJrmlWbyrXyqEI8nP/N31d1yfT314rk3Jr7DS47f6Q27 desktop ssh"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBpp3BCCln5zynpJeXrronEpc/OqhoGNZto66lFNQ6hl laptop"
          ];
          hashedPassword = "$6$bAzgu5Zw0lMpRMLU$n.OHge5ChT9fiJlKJ1ZHY9prbGfEOJJLFDbTzKFYTq91hBRqOjj0eiEwhsztzp6dr48l9NQjcrvQsV6m30E7//";
        };

        # ── Git over SSH ─────────────────────────────────────────────────────
        # Bare repos live in /srv/git.
        # Create:  git init --bare /srv/git/myproject.git
        # Clone:   git clone elias@nixos-nas.local:/srv/git/myproject.git  (LAN)
        #          git clone elias@<zerotier-ip>:/srv/git/myproject.git    (remote)
        custom.git-server.enable = true;

        # ── File sync (Syncthing) ─────────────────────────────────────────
        # Web UI at http://nixos-nas.local:8384 (LAN) or ZeroTier IP:8384.
        # Add nixos-nas as a device in Syncthing on each machine to start syncing.
        custom.syncthing.enable = true;

        # ── Public file sharing (Caddy + Filebrowser) ─────────────────────
        # Replace "files.yourdomain.com" with your actual domain.
        # The domain must have an A record pointing to your home's public IP.
        # Ports 80 and 443 must be forwarded on the router to this machine.
        #
        # Public listing:  https://files.yourdomain.com/  (internet-accessible)
        # File manager:    http://nixos-nas.local:8080    (LAN / ZeroTier only)
        #
        # ZeroTier note: if ProtonVPN routes all traffic, ZeroTier will break.
        # Enable split tunneling in ProtonVPN to exclude the ZeroTier subnet
        # (typically 10.147.0.0/16 — check your ZeroTier network settings).
        custom.fileshare = {
          enable = true;
          domain = "files.eliappo.dk";
        };

        # ── Extra system packages ─────────────────────────────────────────
        environment.systemPackages = with pkgs; [
          rsync  # push/pull files to/from other machines
          tmux   # persistent terminal sessions over SSH
          btop   # system monitor
          ncdu   # disk usage explorer
          lsof   # see what has which files open
        ];

        # ── Home-manager: minimal SSH environment ─────────────────────────
        # No desktop tools, no stylix. Just enough for comfortable SSH sessions.
        home-manager.users.elias.imports = [
          ../../../home/base.nix
          ../../../home/ssh.nix
        ];
      })
    ];
  };
}
