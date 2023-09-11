{ pkgs, ... }: {
  sine =
    frequency: duration:
    pkgs.runCommand
      "sine-${builtins.toString frequency}-${builtins.toString duration}.wav"
      {
        nativeBuildInputs = [ pkgs.sox ];
      }
      ''
        sox -V -r 48000 -n -b 16 -c 2 $out synth ${builtins.toString duration} sin ${builtins.toString frequency} vol -10dB
      '';

  sequence = first: second:
    pkgs.runCommand "sequence.wav"
      {
        nativeBuildInputs = [ pkgs.sox ];
      }
      ''
        sox ${first} ${second} $out
      '';
}
