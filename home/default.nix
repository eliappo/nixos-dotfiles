# Collects all shared home-manager modules. Imported by every host via
# home-manager.users.elias.imports = [ ./home/default.nix ].
{ ... }:

{
  imports = [
    ./base.nix
    ./ssh.nix
    ./terminal.nix
    ./development.nix
    ./desktop.nix
    ./waybar.nix
    ./media.nix
    ./tools.nix
    ./theming.nix
  ];
}
