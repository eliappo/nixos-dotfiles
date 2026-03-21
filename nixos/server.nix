# Server base profile — analogous to nixos/default.nix for desktop hosts.
# Excludes: stylix, desktop environment, audio, bluetooth, wine, gaming.
{ inputs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager

    ./core.nix
    ./boot.nix
    ./networking.nix   # includes zerotierone — NAS joins the same ZeroTier network
    ./users.nix
    ./dev-tools.nix
    ./virtualization.nix

    ./ssh-server.nix   # key-only SSH
    ./git-server.nix   # bare repos over SSH (opt-in)
    ./syncthing.nix    # file sync (opt-in)
    ./fileshare.nix    # Caddy HTTPS + Filebrowser (opt-in)
  ];

  # mDNS: makes the NAS reachable as <hostname>.local on the local network.
  # Combined with ZeroTier, this covers both home (LAN) and away (VPN) access.
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
    };
  };
}
