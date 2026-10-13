# DRAFT — modules/system/networking.nix
#
# Contributes to flake.modules.nixos.networking.
# All networking config in one place: wifi, VPN, overlay networking.
#
# Previously this was scattered across modules/common.nix lines 39-65 and 105.
# No home-manager config for this feature, so only nixos is set.

{ ... }:

let
  secrets = import /home/elias/secrets.nix;
in
{
  flake.modules.nixos.networking = {
    networking.wireless.enable = true;
    networking.wireless.networks = {
      "Nr. 4 5GHz".psk = secrets.wifiPasswords."Nr. 4 5GHz";
      "Rosstova".psk = "Topptur2023";
      "bolig37".psk = secrets.wifiPasswords."bolig37";
      "ITU-Guest" = { };
      eduroam.auth = ''
        key_mgmt=WPA-EAP
        eap=PEAP
        ca_cert="/etc/ssl/certs/eduroam-ca.pem"
        identity="${secrets.wifiPasswords.eduroam.identity}"
        altsubject_match="DNS:network.itu.dk"
        phase2="auth=MSCHAPV2"
        password="${secrets.wifiPasswords.eduroam.password}"
      '';
      "Pixel_8135".psk = secrets.wifiPasswords."Pixel_8135";
    };

    # eduroam certificate
    environment.etc."ssl/certs/eduroam-ca.pem".source = ../../modules/ca.pem;

    services.tailscale.enable = true;
    services.zerotierone.enable = true;

    # Tokens injected as system env vars
    environment.sessionVariables = {
      DIGITAL_OCEAN_TOKEN = secrets.tokens.digital-ocean;
      SSH_KEY_NAME = "digital-ocean-key";
    };
  };
}
