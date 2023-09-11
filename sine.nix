{ pkgs, lib, ... }: rec {
  sine =
    frequency: duration: let seconds = duration / 4; in
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
