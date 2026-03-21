{ pkgs, ... }:

{
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

  home.packages = with pkgs; [
    ## Shell tools
    neovim
    ripgrep
    tree
    fd

    ##Programs
    nil
    nodejs #????
    clang-tools # clang-format, clangd LSP (gcc/clang compiler is in nixos/dev-tools.nix)
    slurp #Get dragged screen dimension
    grim #Screenshot - can take dimension form slurp

    #### Development ####
    ##Rust
    rustup

    ## docker
    docker-compose
    grafana

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
      dbus-python
    ]))

    ##Esp32 development
    cargo-espflash
    espflash
    esp-generate
    espup

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

    arduino-ide
  ];
}
