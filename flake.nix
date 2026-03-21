{
  description = "NixOS Virgin btw";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-code = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    import-tree.url = "github:vic/import-tree";
  };

  # import-tree recursively discovers every .nix under ./modules/ and treats
  # each as a flake-parts module. Adding a new host = adding a file there.
  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ "x86_64-linux" ];
    imports = [ (inputs.import-tree ./modules) ];
  };
}
