# DRAFT — modules/apps/terminal.nix
#
# Everything related to the terminal experience: alacritty, bash, tmux, zoxide, fzf, eza.
# Previously all in home.nix across multiple disconnected sections.
#
# Note: tmux uses stylix colors (config.lib.stylix.colors.*).
# In a deferredModule context, `config` refers to the home-manager config
# when this module is eventually evaluated inside nixosSystem.

{ pkgs, ... }:

{
  flake.modules.homeManager.terminal = { config, lib, ... }: {
    programs.alacritty = {
      enable = true;
      settings.terminal.shell = {
        program = "${pkgs.bash}/bin/bash";
        args = [ "--login" ];
      };
    };

    programs.bash = {
      enable = true;
      shellAliases = {
        btw = "echo I use nixos and I am a virgin now";
        nr = ''echo Rebuild and Switch that mother fucker! &&
               sudo nixos-rebuild switch --impure --flake ~/nixos-dotfiles#$(hostname)'';
        run_pintos = "docker run -it --rm --name pintos --mount type=bind,source=/home/elias/itu/operating_systems_and_C/,target=/home/PKUOS/pintos pkuflyingpig/pintos bash";
        pintos_docker_attach = "docker exec -it pintos bash";
        itu-vpn = "sudo openconnect --protocol=fortinet sslvpn.itu.dk --user=elpo";
        itu-ssh = "ssh elpo@hpc.itu.dk";
        cat = "bat";
      };
      initExtra = ''
        if [ -z "$SSH_AUTH_SOCK" ]; then
          export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent"
        fi
        export RUBYOPT="-W0"
      '';
    };

    programs.tmux = {
      enable = true;
      keyMode = "vi";
      prefix = "C-b";
      mouse = true;
      plugins = with pkgs.tmuxPlugins; [
        {
          plugin = resurrect;
          extraConfig = ''
            set -g @resurrect-dir '~/.tmux/resurrect'
            set -g @resurrect-strategy-vim 'session'
            set -g @resurrect-strategy-nvim 'session'
            set -g @resurrect-capture-pane-contents 'on'
          '';
        }
        {
          plugin = continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
            set -g @continuum-save-interval '5'
            set -g @continuum-boot 'on'
            set -g @resurrect-dir '~/.tmux/resurrect'
          '';
        }
      ];
      extraConfig = with config.lib.stylix.colors; ''
        set -g @resurrect-strategy-vim 'session'
        set -g @resurrect-strategy-nvim 'session'
        set -g @resurrect-capture-pane-contents 'on'
        set -g base-index 1
        set -g pane-base-index 1
        set -g renumber-windows on
        set -g escape-time 0
        set -g focus-events on
        set -g status-position top
        set -g status-left-length 100
        set -g status-style "bg=default,fg=#${base05}"
        set -g window-status-style "bg=default,fg=#${base04}"
        set -g window-status-current-style "bg=default,fg=#${base06},bold"
        set -g window-status-format "#[fg=#${base04}] #I:#W  "
        set -g window-status-current-format "#[fg=#${base06}, bold] #[underscore]#I:#W#[nounderscore] 󰳝 "
        set -g status-left "#[fg=#${base04}, bold]  #S #[fg=#${base05}, nobold] | "
      '';
    };

    programs.zoxide = {
      enable = true;
      enableBashIntegration = true;
      options = [ "--cmd cd" ];
    };

    programs.fzf = {
      enable = true;
      enableBashIntegration = true;
      defaultCommand = "fd --type f --hidden --follow --exclude .git";
      defaultOptions = [ "--height 40%" "--layout=reverse" "--border" "--inline-info" ];
    };

    programs.eza = {
      enable = true;
      git = true;
      colors = "auto";
    };

    home.sessionVariables.SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/ssh-agent";
  };
}
