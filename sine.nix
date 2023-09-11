{ pkgs, lib, ... }: rec {
  frequencies = rec {
    g2 = g3 / 2;
    a2 = a3 / 2;
    b2 = b3 / 2;
    c3 = c4 / 2;
    d3 = d4 / 2;
    a3 = 220;
    b3 = 247;
    g3 = 196;
    c4 = 262;
    d4 = 294;
    e4 = 330;
  };

  sine =
    frequency: duration: vol:
    let seconds = duration / 6; in
    pkgs.runCommand
      "sine-${builtins.toString frequency}-${builtins.toString seconds}.wav"
      {
        nativeBuildInputs = [ pkgs.sox pkgs.calc ];
      }
      ''
        sox -V -r 48000 -n -b 16 -c 2 $out synth ${builtins.toString seconds} sin ${builtins.toString frequency} vol $(calc 'floor(log(${builtins.toString vol}+1)*12-25)')dB
      '';

  square = f: d: vol: overlay [
    (sine f d vol)
    (sine (f*3.0) d (vol / 3.0))
    (sine (f*5.0) d (vol / 5.0))
    (sine (f*7.0) d (vol / 7.0))
    (sine (f*9.0) d (vol / 9.0))
    (sine (f*11.0) d (vol / 11.0))
    (sine (f*13.0) d (vol / 13.0))
  ];

  binarySeq = first: second:
    pkgs.runCommand "sequence.wav"
      {
        nativeBuildInputs = [ pkgs.sox ];
      }
      ''
        sox ${first} ${second} $out
      '';

  sequence = lib.fold binarySeq (sine 14000 0.1 0.0);

  binaryOverlay = first: second:
    pkgs.runCommand "overlay.wav"
      {
        nativeBuildInputs = [ pkgs.ffmpeg ];
      }
      ''
        ffmpeg -i ${first} -i ${second} -filter_complex amix=inputs=2:duration=longest $out
      '';

  overlay = lib.fold binaryOverlay (sine 14000 0.1 0.0);
}
