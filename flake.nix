{
  inputs.flake-utils.url = "github:numtide/flake-utils";
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          rest = 14000;
        in
          with import ./sine.nix { inherit pkgs; lib = nixpkgs.lib; };
          with frequencies;
          with chords;
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
              (cMajor 2.0 100.0)
              (square rest 1.0 0.0)
              (cMajor 2.0 100.0)
              (square rest 1.0 0.0)
              (gMajor 2.0 100.0)
              (square rest 4.0 0.0)
              (gMajor 4.0 100.0)
              (gMajor 2.0 100.0)
              (square rest 1.0 0.0)
              (gMajor 2.0 100.0)
              (square rest 1.0 0.0)
              (aMinor 2.0 100.0)
              (square rest 4.0 0.0)
              (aMinor 3.0 100.0)
              (square rest 1.0 0.0)
              (aMinor 2.0 100.0)
              (square rest 1.0 0.0)
              (aMinor 2.0 100.0)
              (square rest 1.0 0.0)
              (gMajor 2.0 100.0)
              (square rest 7.0 0.0)
              (gMajor 1.0 100.0)
              (gMajor 2.0 100.0)
              (cMajor 2.0 100.0)
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
