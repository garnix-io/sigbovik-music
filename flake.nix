{
  inputs.flake-utils.url = "github:numtide/flake-utils";
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          a3 = 220;
          b3 = 247;
          g3 = 196;
          c4 = 262;
          d4 = 294;
          e4 = 330;
          rest = 14000;
        in
        with import ./sine.nix { inherit pkgs; lib = nixpkgs.lib; };
        {
          packages = rec {
            default = sequence [
              (sine g3 1.0)
              (sine a3 1.0)
              (sine c4 1.0)
              (sine a3 1.0)
              (sine e4 2.0)
              (sine rest 1.0)
              (sine e4 2.0)
              (sine rest 1.0)
              (sine d4 2.0)
              (sine rest 4.0)

              (sine g3 1.0)
              (sine a3 1.0)
              (sine c4 1.0)
              (sine a3 1.0)
              (sine d4 2.0)
              (sine rest 1.0)
              (sine d4 2.0)
              (sine rest 1.0)
              (sine c4 2.0)
              (sine rest 4.0)

              (sine g3 1.0)
              (sine a3 1.0)
              (sine c4 1.0)
              (sine a3 1.0)
              (sine c4 2.0)
              (sine rest 1.0)
              (sine d4 2.0)
              (sine rest 1.0)
              (sine b3 2.0)
              (sine rest 7.0)
              (sine g3 1.0)
              (sine d4 2.0)
              (sine c4 2.0)
            ];

            garnix-music =
              pkgs.runCommand "garnix-music"
                {
                  meta.mainProgram = "song";
                  nativeBuildInputs = [ pkgs.sox ];
                } ''
                mkdir -p $out/bin
                echo ${pkgs.sox}/bin/play ${default} >$out/bin/song
                chmod +x $out/bin/song
              '';
          };

          formatter = pkgs.nixpkgs-fmt;
        }
      );
}
