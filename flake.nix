{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    roc.url = "github:roc-lang/roc?rev=0295bb58da3de1dec84f63b5a1847ff32a3fd290";
  };

  nixConfig = {
    extra-trusted-public-keys = "roc-lang.cachix.org-1:6lZeqLP9SadjmUbskJAvcdGR2T5ViR57pDVkxJQb8R4=";
    extra-trusted-substituters = "https://roc-lang.cachix.org";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      roc,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      perSystem =
        { inputs', pkgs, ... }:
        {
          devShells.default = pkgs.mkShell {
            name = "roc-html";
            packages = [
              inputs'.roc.packages.cli
              pkgs.actionlint
              pkgs.check-jsonschema
              pkgs.fd
              pkgs.just
              pkgs.nixfmt-rfc-style
              pkgs.nodePackages.prettier
              pkgs.pre-commit
              pkgs.python312Packages.pre-commit-hooks
            ];
            shellHook = "pre-commit install --overwrite";
          };
          formatter = pkgs.nixfmt-rfc-style;
        };
    };
}
