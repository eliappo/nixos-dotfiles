# DRAFT — dendritic flake.nix
#
# Compared to the current flake.nix (~58 lines):
#   - No manual commonModules list
#   - No hostName threading via extraSpecialArgs
#   - No manual host registration (that moves into modules/hosts/)
#   - All orchestration is handled by flake-parts + import-tree
#   - This file never needs to change when you add features or hosts
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

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    imports = [
      # Enable the flake.modules staging area (for dendritic co-location).
      # This provides the flake.modules.nixos and flake.modules.homeManager options.
      inputs.flake-parts.flakeModules.modules

      # Recursively import every .nix file under ./modules/.
      # Files/dirs starting with _ are excluded (used for shared helpers).
      (inputs.import-tree ./modules)
    ];

    # Architectures this flake targets. perSystem modules are evaluated once per entry.
    systems = [ "x86_64-linux" ];
  };
}
