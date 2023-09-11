{
  inputs.flake-utils.url = "github:numtide/flake-utils";
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};

        in
        with import ./sine.nix { inherit pkgs; };
        {
          packages = {
            default = sequence (sine 440 1) (sine 256 1);
          };

          formatter = pkgs.nixpkgs-fmt;
        }
      );
}
