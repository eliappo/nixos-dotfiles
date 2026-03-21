{ ... }:

{
  home.username = "elias";
  home.homeDirectory = "/home/elias";
  home.stateVersion = "25.05";

  home.sessionVariables = {
    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/ssh-agent";
  };

  fonts.fontconfig.enable = true;
}
