let
  pkgs = import <nixpkgs> { };
in
pkgs.callPackage ./sine.nix { }
