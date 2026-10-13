# DRAFT — modules/apps/development.nix
#
# All development tooling: git, editors, language runtimes, LSPs.
# Previously spread across home.nix lines 80-91 (git/vscode),
# 514-599 (packages section), plus common.nix (gcc/clang/cmake duplicated).
#
# NixOS side: none (build tools are in system/core.nix).
# HM side: user-level dev tools and language environments.

{ pkgs, ... }:

{
  flake.modules.homeManager.development = {
    programs.git = {
      enable = true;
      userName = "eliappo";
      userEmail = "237402327+eliappo@users.noreply.github.com";
      extraConfig = {
        init.defaultBranch = "main";
        pull.rebase = "false";
        core.editor = "nvim";
      };
    };

    programs.vscode.enable = true;
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

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

    home.packages = with pkgs; [
      neovim
      ripgrep
      fd
      nil          # Nix LSP

      # Rust
      rustup
      cargo-espflash
      espflash
      esp-generate
      espup

      # Go
      go_1_25
      gopls
      gotools
      go-outline
      delve

      # Python
      (python312.withPackages (ps: with ps; [
        numpy
        requests
        pandas
        flask
        pip
        virtualenv
        werkzeug
        dbus-python
      ]))

      # Java
      jdk21
      jdt-language-server
      vscode-extensions.vscjava.vscode-java-debug
      gradle

      # Misc dev utilities
      nodejs
      clang-tools
      docker-compose
      grafana
      jq
      nixpkgs-fmt

      # Arduino / embedded
      arduino-ide
    ];
  };
}
