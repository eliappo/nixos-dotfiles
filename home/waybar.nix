{ lib, ... }:

{
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
          "chardware.pulseaudio.enable = true;ustom/sep"
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
          format = " {volume}% ";
          format-muted = " Muted";
          on-click = "pavucontrol"; #FIX: Need to be added
        };
        network = {
          format-wifi = " {essid}   ({signalStrength}%)";
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
          format-charging = " {capacity}% ";
          format-plugged = " {capacity}% ";
          format-icons = [ "" "" "" "" "" ];
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
          format = "{status} ";
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
}
