{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      perSystem =
        {
          pkgs,
          lib,
          self',
          ...
        }:
        {
          devShells.default = pkgs.haskellPackages.shellFor {
            nativeBuildInputs = [
              pkgs.cabal2nix
              pkgs.haskell-language-server
              pkgs.haskellPackages.Cabal
              pkgs.haskellPackages.fourmolu
              pkgs.pandoc
            ];

            packages = p: [ self'.packages.neorg-haskell-parser ];
          };

          packages =
            let
              base = pkgs.haskellPackages.callPackage ./neorg-haskell-parser.nix { };
            in
            {
              neorg-haskell-parser = lib.pipe base (
                with pkgs.haskell.lib;
                [
                  doJailbreak
                  dontCheck
                  dontHaddock
                  justStaticExecutables
                ]
              );

              neorg-haskell-parser-full = base.overrideAttrs (
                _: prev: {
                  buildInputs = prev.buildInputs ++ [ pkgs.pandoc ];
                }
              );
            };
        };
    };
}
