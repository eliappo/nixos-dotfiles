{ config, pkgs, lib, ... }:

let
  dotfiles = "${config.home.homeDirectory}/nixos-dotfiles/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
  configs = {
    qtile = "qtile";
    nvim = "nvim";
    rofi = "rofi";
    kanata = "kanata";
    hypr = "hypr";
  };
  myscripts = import ./scripts.nix { inherit pkgs; };
  #Waybar related
  # Helper to convert 2-digit hex string to decimal
  #hexToDec = hex:
  #  let
  #    chars = lib.stringToCharacters hex;
  #    hexDigit = c:
  #      if c == "0" then 0 else if c == "1" then 1
  #      else if c == "2" then 2 else if c == "3" then 3
  #      else if c == "4" then 4 else if c == "5" then 5
  #      else if c == "6" then 6 else if c == "7" then 7
  #      else if c == "8" then 8 else if c == "9" then 9
  #      else if c == "a" || c == "A" then 10
  #      else if c == "b" || c == "B" then 11
  #      else if c == "c" || c == "C" then 12
  #      else if c == "d" || c == "D" then 13
  #      else if c == "e" || c == "E" then 14
  #      else if c == "f" || c == "F" then 15
  #      else 0;
  #  in
  #  (hexDigit (builtins.elemAt chars 0)) * 16 +
  #  (hexDigit (builtins.elemAt chars 1));

  #baseColor = config.lib.stylix.colors.base00;
  #r = hexToDec (builtins.substring 0 2 baseColor);
  #g = hexToDec (builtins.substring 2 2 baseColor);
  #b = hexToDec (builtins.substring 4 2 baseColor);
in
{
  home.sessionVariables = {
    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/ssh-agent";
  };
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
      "cos.itu.dk" = {
        hostname = "cos.itu.dk";
        user = "elpo";
        identityFile = "~/.ssh/id_ed25519";
      };
    };
  };
  services.ssh-agent.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.vscode.enable = true;

  programs.git = {
    enable = true;
    userName = "eliappo";
    userEmail = "237402327+eliappo@users.noreply.github.com";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = "false";
    };
  };

  programs.eza = {
    enable = true;
    git = true;
    colors = "auto";
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
        reload_style_on_change = true;
        layer = "top";
        position = "top";
        height = 30;
        modules-left = [
          "hyprland/workspaces"
          "custom/sep"
          "hyprland/window"
        ];
        modules-center = [ ];
        modules-right = [
          "custom/sep"
          "pulseaudio"
          "custom/sep"
          "bluetooth"
          "custom/sep"
          "network"
          "custom/sep"
          "cpu"
          "custom/sep"
          "memory"
          "custom/sep"
          "disk"
          "custom/sep"
          "battery"
          "custom/sep"
          "clock"
          "custom/sep"
          "tray"
        ];
        "hyprland/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          warp-on-scroll = false;
          format = "{name}";
          persistent-workspaces."*" = [ 1 2 3 4 5 6 7 8 9 ];
        };
        "hyprland/window" = {
          max-length = 40;
          separate-outputs = false;
        };
        pulseaudio = {
          format = " {volume}% ";
          format-muted = " Muted";
          on-click = "pavucontrol"; #FIX: Need to be added
        };
        network = {
          format-wifi = " {essid}   ({signalStrength}%)";
          format-ethernet = " {ifname}";
          format-disconnected = " Disconnected ⚠";
          tooltip-format = "{ipaddr}";
        };
        cpu = {
          format = "CPU: 󰻠 {usage}%";
          tooltip = false;
        };
        memory = {
          format = "Mem: 󰍛 {used}GiB";
          tooltip-format = "{used:0.1f}G / {total:0.1f}G used";
        };
        battery = {
          states = {
            good = 95;
            warning = 30;
            critical = 15;
          };
          format = "Bat: {capacity}% {icon}  {time}";
          format-charging = " {capacity}% ";
          format-plugged = " {capacity}% ";
          format-icons = [ "" "" "" "" "" ];
        };
        tray.spacing = 10;
        clock = {
          format = " {:%H:%M}";
          format-alt = " {:%Y-%m-%d}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };
        disk = {
          interval = 60;
          path = "/";
          format = "Disk {free}";
        };
        "custom/sep" = {
          format = "|";
          interval = 0;
        };
        bluetooth = {
          format = "{status} ";
          format-connected = "{device_alias} 󰂱";
          format-connected-battery = " {device_alias} 󰂱 {device_battery_percentage}%";
          tooltip-format = "{controller_alias}\t{controller_address}";
          tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
          on-click = "blueman-manager"; #Not present
        };
      };
    };
    style = lib.mkAfter ''
      @define-color bg    #1a1b26; 
      @define-color fg    #a9b1d6; 
      @define-color blk   #32344a; 
      @define-color red   #f7768e; 
      @define-color grn   #9ece6a; 
      @define-color ylw   #e0af68; 
      @define-color blu   #7aa2f7; 
      @define-color mag   #ad8ee6; 
      @define-color cyn   #0db9d7; 
      @define-color brblk #444b6a; 
      @define-color white #ffffff; 
      @define-color bg-trans rgba(26,27,38,0.9);

      * {
          font-family: "JetBrainsMono Nerd Font", monospace;
          font-size: 16px;
          font-weight: bold;
      }

      window#waybar {
          background-color: @bg-trans;
          color: @fg;
      }

      #workspaces button {
          padding: 0 6px;
          color: @cyn;
          background: transparent;
          border-bottom: 3px solid @bg;
      }
      #workspaces button.active {
          color: @cyn;
          border-bottom: 3px solid @mag;
      }
      #workspaces button.empty {
          color: @white;
      }
      #workspaces button.empty.active {
          color: @cyn;
          border-bottom: 3px solid @mag;
      }

      #workspaces button.urgent {
          background-color: @red;
      }

      button:hover {
          background: inherit;
          box-shadow: inset 0 -3px #ffffff;
      }

      #clock,
      #custom-sep,
      #battery,
      #cpu,
      #memory,
      #disk,
      #network,
      #bluetooth,
      #pulseaudio,
      #tray {
          padding: 0 8px;
          color: @white;
      }

      #custom-sep {
          color: @brblk;
      }

      #clock {
          color: @cyn;
          border-bottom: 4px solid @cyn;
      }

      #battery {
          color: @mag;
          border-bottom: 4px solid @mag;
      }

      #disk {
          color: @ylw;
          border-bottom: 4px solid @ylw;
      }

      #memory {
          color: @mag;
          border-bottom: 4px solid @mag;
      }

      #cpu {
          color: @grn;
          border-bottom: 4px solid @grn;
      }

      #network {
          color: @blu;
          border-bottom: 4px solid @blu;
      }

      #network.disconnected {
          background-color: @red;
      }
      #bluetooth {
          color: @cyn;
          border-bottom: 4px solid @cyn;
      }
      #pulseaudio {
          color: @mag;
          border-bottom: 4px solid @mag;
      }

      #tray {
          background-color: #2980b9;
      }
    '';
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
      pintos_docker_attach = "docker exec -it pintos bash";
    };
    initExtra = ''
      if [ -z "$SSH_AUTH_SOCK" ]; then
        export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent"
      fi
    '';
  };

  xdg.configFile = builtins.mapAttrs
    (name: subpath: {
      source = create_symlink "${dotfiles}/${subpath}";
      recursive = true;
    })
    configs;

  systemd.user.services.kanata-builtin = {
    Unit = {
      Description = "Kanata keyboard layout for builtin and regular keyboards";
      Documentation = "https://github.com/jtroo/kanata";
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.kanata}/bin/kanata --cfg ${dotfiles}/kanata/kanata-builtin.kbd.lisp";
      Restart = "on-failure";
      RestartSec = "5s";
      StartLimitBurst = 3;
      StartLimitIntervalSec = "60s";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  systemd.user.services.kanata-kinesis = {
    Unit = {
      Description = "Kanata keyboard layout for the kinesis keyboard";
      Documentation = "https://github.com/jtroo/kanata";
      ConditionPathExists = "/dev/input/by-path/pci-0000:00:14.0-usbv2-0:6:1.1-event-kbd";
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.kanata}/bin/kanata --cfg ${dotfiles}/kanata/kanata-kinesis.kbd.lisp";
      Restart = "on-failure";
      RestartSec = "5s";
      StartLimitBurst = 3;
      StartLimitIntervalSec = "60s";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  programs.mpv.enable = true;
  programs.zathura.enable = true;

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
    obsidian #Note Tool
    pastel
    astroterm
    (obs-studio.override {
      cudaSupport = true;
    })

    #### Development ####
    ##Rust
    rustup

    ## docker
    docker-compose

    ## Go-lang
    go_1_25
    gopls #go lsp
    gotools # Extra go tooling
    go-outline # code outline 
    delve # debugger

    ##Python
    (python312.withPackages (ps: with ps; [
      numpy
      requests
      pandas
      flask
      pip
      virtualenv
      werkzeug
    ]))

    ##Esp32 development
    cargo-espflash
    espflash
    esp-generate
    espup

    ## Utils
    unzip
    btop


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

    # Java Development Kit
    jdk21
    # Language Server Protocol
    jdt-language-server
    # Java debug adapter
    vscode-extensions.vscjava.vscode-java-debug
    # Build tools
    gradle
    # Additional useful tools
    jq

    freecad
    (pkgs.prusa-slicer.overrideAttrs (old: {
      nativeBuildInputs = old.nativeBuildInputs or [ ] ++ [ pkgs.makeWrapper ];
      postInstall = (old.postInstall or "") + ''
        wrapProgram $out/bin/prusa-slicer \
          --set __GLX_VENDOR_LIBRARY_NAME mesa \
          --set MESA_LOADER_DRIVER_OVERRIDE zink \
          --set GALLIUM_DRIVER zink
      '';
    }))
    graphviz

    # Muggler text app
    libreoffice
  ];

  fonts.fontconfig.enable = true;

}

