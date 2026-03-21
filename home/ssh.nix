{ ... }:

{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519";
      };
      "cos.itu.dk" = {
        hostname = "cos.itu.dk";
        user = "elpo";
        identityFile = "~/.ssh/id_ed25519";
      };
      "digital-ocean" = {
        hostname = "digitalocean.com";
        user = "eliappo";
        identityFile = "~/.ssh/digital-ocean-key";
      };
    };
  };

  services.ssh-agent.enable = true;
}
