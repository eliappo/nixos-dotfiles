{ config, pkgs, ... }:

let
  secrets = import /home/elias/secrets.nix; #Place your secrets outside of the flake-directory because git.
  hostName = config.networking.hostName;

  # Networks every host knows. Each referenced key exists in all three hosts'
  # secrets.nix, so this base is safe everywhere.
  commonNetworks = {
    "Rosstova" = {
      #Summerhouse in Norway
      psk = "Topptur2023";
    };
    "bolig37" = {
      psk = secrets.wifiPasswords."bolig37";
    };
    "ITU-Guest" = { };
    eduroam = {
      auth = ''
        key_mgmt=WPA-EAP
        eap=PEAP
        ca_cert="/etc/ssl/certs/eduroam-ca.pem"
        identity="${secrets.wifiPasswords.eduroam.identity}"
        altsubject_match="DNS:network.itu.dk"
        phase2="auth=MSCHAPV2"
        password="${secrets.wifiPasswords.eduroam.password}"
      '';
    };
    "Pixel_8135".psk = secrets.wifiPasswords."Pixel_8135";
  };

  # Per-host extras. Each host only references PSK keys present in its own
  # secrets.nix — that's why wifi is split per host rather than shared.
  hostNetworks = {
    nixos-desktop = {
      "Nr. 4 5GHz".psk = secrets.wifiPasswords."Nr. 4 5GHz";
    };
    nixos-nas = {
      "Nr. 4 5GHz".psk = secrets.wifiPasswords."Nr. 4 5GHz";
    };
    nixos-virgin = {
      "Wormhole".psk = secrets.wifiPasswords."Wormhole";
      "TP-Link_B848_5G" = {
        #Tine og Storms wifi
        psk = "87548815";
      };
      "laroggia".psk = secrets.wifiPasswords."laroggia";
      "Ungdom_5G".psk = secrets.wifiPasswords."Ungdom_5G";
    };
  };
in
{
  networking.wireless.enable = true;
  networking.wireless.networks = commonNetworks // (hostNetworks.${hostName} or { });

  environment.etc."ssl/certs/eduroam-ca.pem".source = ./ca.pem;

  environment.systemPackages = with pkgs; [
    openconnect #open source vpn tunnel
    vagrant #Virtualization tool
  ];

  services.zerotierone.enable = true;

  # ZeroTier iface name is derived from the network id, so it is the same on
  # every host that joins. Trusting it + loose reverse-path keeps ZeroTier
  # traffic flowing through the firewall.
  networking.firewall = {
    enable = true;
    checkReversePath = "loose";
    trustedInterfaces = [ "ztcdco5y2h" ];
  };

  environment.sessionVariables = {
    DIGITAL_OCEAN_TOKEN = secrets.tokens.digital-ocean;
    SSH_KEY_NAME = if hostName == "nixos-virgin" then "X1 Laptop" else "digital-ocean-key";
  };
}
