{
  inputs.flake-utils.url = "github:numtide/flake-utils";
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          g2 = g3 / 2;
          a2 = a3 / 2;
          c3 = c4 / 2;
          d3 = d4 / 2;
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
            melody = sequence [
              (sine g3 1.0 50.0)
              (sine a3 1.0 50.0)
              (sine c4 1.0 50.0)
              (sine a3 1.0 50.0)
              (sine e4 2.0 50.0)
              (sine rest 1.0 0.0)
              (sine e4 2.0 50.0)
              (sine rest 1.0 0.0)
              (sine d4 2.0 50.0)
              (sine rest 4.0 0.0)

              (sine g3 1.0 50.0)
              (sine a3 1.0 50.0)
              (sine c4 1.0 50.0)
              (sine a3 1.0 50.0)
              (sine d4 2.0 50.0)
              (sine rest 1.0 0.0)
              (sine d4 2.0 50.0)
              (sine rest 1.0 0.0)
              (sine c4 2.0 50.0)
              (sine rest 4.0 0.0)

              (sine g3 1.0 50.0)
              (sine a3 1.0 50.0)
              (sine c4 1.0 50.0)
              (sine a3 1.0 50.0)
              (sine c4 2.0 50.0)
              (sine rest 1.0 0.0)
              (sine d4 2.0 50.0)
              (sine rest 1.0 0.0)
              (sine b3 2.0 50.0)
              (sine rest 7.0 0.0)
              (sine g3 1.0 50.0)
              (sine d4 2.0 50.0)
              (sine c4 2.0 50.0)
            ];
            bass = sequence [
              (square rest 4.0 0.0)
              (square c3 2.0 100.0)
              (square rest 1.0 0.0)
              (square c3 2.0 100.0)
              (square rest 1.0 0.0)
              (square d3 2.0 100.0)
              (square rest 4.0 0.0)
              (square g2 4.0 100.0)
              (square g2 2.0 100.0)
              (square rest 1.0 0.0)
              (square g2 2.0 100.0)
              (square rest 1.0 0.0)
              (square a2 2.0 100.0)
              (square rest 4.0 0.0)
              (square a2 3.0 100.0)
              (square rest 1.0 0.0)
              (square a2 2.0 100.0)
              (square rest 1.0 0.0)
              (square a2 2.0 100.0)
              (square rest 1.0 0.0)
              (square g2 2.0 100.0)
              (square rest 7.0 0.0)
              (square g2 1.0 100.0)
              (square g2 2.0 100.0)
              (square c3 2.0 100.0)
            ];
            song = overlay [ melody bass ];
            default =
              pkgs.runCommand "garnix-music"
                {
                  meta.mainProgram = "song";
                  nativeBuildInputs = [ pkgs.sox ];
                } ''
                mkdir -p $out/bin
                echo ${pkgs.sox}/bin/play ${song} >$out/bin/song
                chmod +x $out/bin/song
              '';
          };

          formatter = pkgs.nixpkgs-fmt;
        }
      );
}
