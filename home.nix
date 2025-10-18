{ config, pkgs, ... }:

let
  dotfiles = "${config.home.homeDirectory}/nixos-dotfiles/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
  configs = {
    qtile = "qtile";
    nvim = "nvim";
    # alacritty = "alacritty";
    rofi = "rofi";
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
      {
        plugin = resurrect;
        extraConfig = ''
          # Set save directory explicitly
          set -g @resurrect-dir '~/.tmux/resurrect'
          set -g @resurrect-strategy-vim 'session'
          set -g @resurrect-strategy-nvim 'session'
          set -g @resurrect-capture-pane-contents 'on'
        '';
      }
      # Automatic saving and restoring
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '5'  # Save every 5 minutes
          set -g @continuum-boot 'on'  # Auto-start tmux on boot
          set -g @resurrect-dir '~/.tmux/resurrect'
        '';
      }
    ];
    extraConfig = with config.lib.stylix.colors; ''
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

          # Native Style config
          set -g status-position top
          set -g status-left-length 100
          # Base status bar - transparent
          set -g status-style "bg=default,fg=#${base05}"
          
          # Base window status styles (these set the defaults)
          set -g window-status-style "bg=default,fg=#${base04}"
          set -g window-status-current-style "bg=default,fg=#${base06},bold"
          
          # Now the formats (without bg= in them)
          set -g window-status-format "#[fg=#${base04}] #I:#W  "
          set -g window-status-current-format "#[fg=#${base06}, bold] #[underscore]#I:#W#[nounderscore] 󰳝 "
          
          # Status left/right
          set -g status-left "#[fg=#${base04}, bold]  #S #[fg=#${base05}, nobold] | "
          #Optional room for more info.
          #set -g status-right "#[fg=#${base04}] %H:%M "

      # For showing actual colors within editor - Ignore!
      # "base00": "#071e28",
      # "base01": "#174d5b",
      # "base02": "#347380",
      # "base03": "#85a3a9",
      # "base04": "#a6bdbf",
      # "base05": "#cbe8e6",
      # "base06": "#d9f6ee",
      # "base07": "#dcf5f8",
      # "base08": "#8a938e",
      # "base09": "#939183",
      # "base0A": "#9e8e82",
      # "base0B": "#6b97a6",
      # "base0C": "#619a9d",
      # "base0D": "#7a9699",
      # "base0E": "#8c9298",
      # "base0F": "#7f94a1",
    '';
  };

  home.stateVersion = "25.05";

  stylix.targets.rofi.enable = false;

  programs.waybar = {
    enable = true;
    settings = {
      mainbar = {
        modules-right = [ "pulseaudio" "network" "bluetooth" "cpu" "memory" "battery" "tray" "clock" ];
        bluetooth = {
          format = " {status}";
          format-connected = " {device_alias}";
          format-connected-battery = " {device_alias} {device_battery_percentage}%";
          tooltip-format = "{controller_alias}\t{controller_address}";
          tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
          on-click = "blueman-manager";
        };
      };
    };
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    options = [ "--cmd cd" ];
  };

  programs.alacritty = {
    enable = true;
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

  programs.obsidian.enable = true;

  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  home.packages = with pkgs; [
    ## Shell tools
    neovim
    ripgrep
    tree
    fd
    myscripts.pintos-symlink #Pintos related scripts for OSandC course.
    myscripts.screen-shot-drag #Dragged screen shot to clipboard.

    ##Programs
    nil
    nodejs #????
    gcc #GNU C compiler NOTE: Both inside the configuration.nix and home.nix FIX:?
    clang-tools
    slurp #Get dragged screen dimension
    grim #Screenshot - can take dimension form slurp

    ## System appearance
    hyprpaper
    hyprpicker
    nixpkgs-fmt
    rofi
    kanata
    font-awesome
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    papirus-icon-theme
  ];

  fonts.fontconfig.enable = true;

}

