{ pkgs, lib, ... }: rec {
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

  getCount = sound: if sound ? count then sound.count else 1;

  binarySeq = first: second:
    let sum = getCount first + getCount second;
    in
    (pkgs.runCommand "sequence-of-${builtins.toString sum}-notes.wav"
      {
        nativeBuildInputs = [ pkgs.sox ];
      }
      ''
        sox ${first} ${second} $out
      '') // { count = sum; };

  sequence = lib.fold binarySeq (sine 14000 0.1);

  binaryOverlay = first: second:
    let sum = getCount first + getCount second;
    in
    (pkgs.runCommand "overlay-of-${builtins.toString sum}-notes.wav"
      {
        nativeBuildInputs = [ pkgs.ffmpeg ];
      }
      ''
        ffmpeg -i ${first} -i ${second} -filter_complex amix=inputs=2:duration=longest $out
      '') // { count = sum; };

  overlay = lib.fold binaryOverlay (sine 14000 0.1);
}
