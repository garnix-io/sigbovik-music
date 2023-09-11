{
  inputs.flake-utils.url = "github:numtide/flake-utils";
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          sine = import ./sine.nix { inherit pkgs; };
        in
        {
          packages = {
            default = sine 440 1;
          };
        }
      );
}
