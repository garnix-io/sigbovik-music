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
    frequency: duration:
    let seconds = duration / 6; in
    pkgs.runCommand
      "sine-${builtins.toString frequency}-${builtins.toString seconds}.wav"
      {
        nativeBuildInputs = [ pkgs.sox ];
      }
      ''
        sox -V -r 48000 -n -b 16 -c 2 $out synth ${builtins.toString seconds} sin ${builtins.toString frequency} vol -10dB
      '';

  binarySeq = first: second:
    pkgs.runCommand "sequence.wav"
      {
        nativeBuildInputs = [ pkgs.sox ];
      }
      ''
        sox ${first} ${second} $out
      '';

  sequence = lib.fold binarySeq (sine 14000 0.1);

  binaryOverlay = first: second:
    pkgs.runCommand "overlay.wav"
      {
        nativeBuildInputs = [ pkgs.ffmpeg ];
      }
      ''
        ffmpeg -i ${first} -i ${second} -filter_complex amix=inputs=2:duration=longest $out
      '';

  overlay = lib.fold binaryOverlay (sine 14000 0.1);
}
