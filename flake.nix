{
  description = "disnoisy: A simple implementation of discord e2e";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.pypi-deps-db = {
    url = "github:DavHau/pypi-deps-db";
    flake = false;
  };
  inputs.mach-nix = {
    url = "github:DavHau/mach-nix?ref=3.3.0";
    inputs = {
      nixpkgs.follows = "nixpkgs";
      flake-utils.follows = "flake-utils";
      pypi-deps-db.follows = "pypi-deps-db";
    };
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    flake-utils.lib.eachDefaultSystem
      (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          mach-nix = inputs.mach-nix.lib."${system}";
        in
        rec {
          devShell = mach-nix.mkPythonShell {
            requirements = ''
              noiseprotocol
              websocket-server
              typer
            '';
          };
          packages.disnoisy = mach-nix.buildPythonApplication {
            pname = "disnoisy";
            version = "0.1.0";
            src = ./.;
            requirements = ''
              noiseprotocol
              websocket-server
              typer
            '';
          };
          defaultPackage = packages.disnoisy;
        }
      );
}
