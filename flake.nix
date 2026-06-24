{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    roc.url = "github:roc-lang/roc?dir=src";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
      perSystem =
        { inputs', pkgs, ... }:
        {
          devShells.default = pkgs.mkShell {
            packages = [
              inputs'.roc.packages.roc
            ]
            # Pre-commit
            ++ [
              pkgs.actionlint
              pkgs.check-jsonschema
              pkgs.fd
              pkgs.just
              pkgs.nixfmt
              pkgs.pre-commit
              pkgs.prettier
              pkgs.python3Packages.pre-commit-hooks
              pkgs.ratchet
            ];
          };
          formatter = pkgs.nixfmt-tree;
        };
    };
}
