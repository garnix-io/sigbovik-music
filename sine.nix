{ pkgs, lib, ... }: rec {
  frequencies = {
    g2 = fromMidi 43;
    a2 = fromMidi 45;
    b2 = fromMidi 47;
    c3 = fromMidi 48;
    d3 = fromMidi 50;
    g3 = fromMidi 55;
    a3 = fromMidi 57;
    b3 = fromMidi 59;
    c4 = fromMidi 60;
    d4 = fromMidi 62;
    e4 = fromMidi 64;
  };

  fromMidi = midi: 440 * (power (power 2.0 (1.0 / 12.0)) (midi - 69.0));

  power = a: b:
    let
      result = pkgs.runCommand
        "power of ${builtins.toString a} and ${builtins.toString b}"
        {
          nativeBuildInputs = [ pkgs.python3 ];
        }
        ''
          python3 -c "print(pow(${builtins.toString a}, ${builtins.toString b}))" > $out
        '';
    in
    import result;

  sine =
    frequency: duration: vol:
    let seconds = duration / 6; in
    pkgs.runCommand
      "sine-${builtins.toString frequency}-${builtins.toString seconds}.wav"
      {
        nativeBuildInputs = [ pkgs.sox pkgs.calc ];
      }
      ''
        sox -V -r 48000 -n -b 16 -c 2 $out synth ${builtins.toString seconds} sin ${builtins.toString frequency} vol ${builtins.toString (vol / 100)}
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
