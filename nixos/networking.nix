{ ... }:

let
  secrets = import /home/elias/secrets.nix; #Place your secrets outside of the flake-directory because git.
in
{
  networking.wireless.enable = true;
  networking.wireless.networks = {
    "Nr. 4 5GHz" = {
      psk = secrets.wifiPasswords."Nr. 4 5GHz";
    };
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
  environment.etc."ssl/certs/eduroam-ca.pem".source = ./ca.pem;

  services.tailscale.enable = true;
  services.zerotierone.enable = true;

  environment.sessionVariables = {
    DIGITAL_OCEAN_TOKEN = secrets.tokens.digital-ocean;
    SSH_KEY_NAME = "digital-ocean-key";
  };
}
