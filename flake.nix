{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";
    rust-flake.url = "github:juspay/rust-flake";
    rust-flake.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;
      imports = [
        inputs.rust-flake.flakeModules.default
        inputs.rust-flake.flakeModules.nixpkgs
      ];
      perSystem = { config, self', pkgs, lib, ... }: {
        rust-project.crates."grsync".crane.args = {
          buildInputs = lib.optionals pkgs.stdenv.isDarwin (
            with pkgs.darwin.apple_sdk.frameworks; [
              SystemConfiguration
            ]
          );
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = [
            self'.devShells.rust
          ];
          packages = [
            pkgs.cargo-watch
          ];
        };
        packages.default = self'.packages.grsync;
      };
    };
}
