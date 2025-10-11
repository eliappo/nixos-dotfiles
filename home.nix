{ config, pkgs, ... }:

let
  dotfiles = "${config.home.homeDirectory}/nixos-dotfiles/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
  configs = {
    qtile = "qtile";
    nvim = "nvim";
    # alacritty = "alacritty";
    # rofi = "rofi";
    kanata = "kanata";
    hypr = "hypr";
    # waybar = "waybar";
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


  programs.fzf = {
    enable = true;
    enableBashIntegration = true; # Adds Ctrl+T, Ctrl+R, Alt+C keybindings
    # Optional: customize appearance
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
      "--inline-info"
    ];
  };

  programs.tmux = {
    enable = true;
    keyMode = "vi";
    prefix = "C-b";

    # Enable mouse support
    mouse = true;

    # Plugins for session persistence
    plugins = with pkgs.tmuxPlugins; [
      # Saves and restores tmux sessions
      resurrect
      # Automatic saving and restoring
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '15'  # Save every 15 minutes
          set -g @continuum-boot 'on'  # Auto-start tmux on boot
        '';
      }
      # Optional: Better status bar
      {
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavour 'mocha'
        '';
      }
    ];
    extraConfig = ''
      # Restore vim sessions too (if using vim)
      set -g @resurrect-strategy-vim 'session'
      set -g @resurrect-strategy-nvim 'session'
      
      # Capture pane contents
      set -g @resurrect-capture-pane-contents 'on'
      
      # Start window numbering at 1
      set -g base-index 1
      set -g pane-base-index 1
      
      # Renumber windows when one is closed
      set -g renumber-windows on

      set -g escape-time 0
      set -g focus-events on
    '';
  };

  home.stateVersion = "25.05";

  # NOTE: Should be movedd intooo stylix!
  home.pointerCursor = {
    name = "Vanilla-DMZ";
    package = pkgs.vanilla-dmz;
    size = 24;
    gtk.enable = true;
  };

  programs.rofi.enable = true;
  programs.waybar.enable = true;
  programs.alacritty = {
    enable = true;
    #    settings = {
    #      font = {
    #        size = 18;
    #      };
    #    };
  };
  # programs.alacritty.extraConfigFile = "${dotfiles}/alacritty/alacritty.toml"; #Probably a hallucination

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
    #    rofi
    kanata
    myscripts.pintos-symlink #Pintos related scripts for OSandC course.
    tree
    fd
    font-awesome
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
  ];

  fonts.fontconfig.enable = true;

}

