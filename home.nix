{ config, pkgs, ... }:

let
  dotfiles = "${config.home.homeDirectory}/nixos-dotfiles/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
  configs = {
    qtile = "qtile";
    nvim = "nvim";
    alacritty = "alacritty";
    rofi = "rofi";
    kanata = "kanata";
    hypr = "hypr";
    waybar = "waybar";
  };
  myscripts = import ./scripts.nix { inherit pkgs; };
in
{
  home.username = "elias";
  home.homeDirectory = "/home/elias";
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519";
      };
    };
  };
  programs.git = {
    enable = true;
    userName = "eliappo";
    userEmail = "237402327+eliappo@users.noreply.github.com";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = "false";
    };
  };
  home.stateVersion = "25.05";

  home.pointerCursor = {
    name = "Vanilla-DMZ";
    package = pkgs.vanilla-dmz;
    size = 24;
    gtk.enable = true;
  };

  programs.bash = {
    enable = true;
    shellAliases = {
      btw = "echo I use nixos and I am a virgin now";
      nr = ''echo Rebuild and Switch that mother fucker! &&
             sudo nixos-rebuild switch --impure --flake ~/nixos-dotfiles#nixos-virgin'';
      run_pintos = "docker run -it --rm --name pintos --mount type=bind,source=/home/elias/itu/operating_systems_and_C/,target=/home/PKUOS/pintos pkuflyingpig/pintos bash";
    };
  };

  xdg.configFile = builtins.mapAttrs
    (name: subpath: {
      source = create_symlink "${dotfiles}/${subpath}";
      recursive = true;
    })
    configs;

  systemd.user.services.kanata = {
    Unit = {
      Description = "Kanata keyboard layout";
      Documentation = "https://github.com/jtroo/kanata";
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.kanata}/bin/kanata --cfg ${dotfiles}/kanata/kanata.kbd.lisp";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  home.packages = with pkgs; [
    neovim
    ripgrep
    nil
    nixpkgs-fmt
    nodejs
    gcc
    rofi
    kanata
    myscripts.pintos-symlink #Pintos related scripts for OSandC course.
  ];

}

