{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    bear #Create compile-commands.json for clangd lsp
    cmake
    gnumake
    gcc #good ol' C compiler for serious programs
    clang #C compiler
  ];
}
