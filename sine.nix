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
    g4 = fromMidi 67;
  };
  chords = with frequencies; {
    cMajor = chord [ c3 e4 g4 ];
    gMajor = chord [ g2 b3 d3 ];
    aMinor = chord [ a2 c4 e4 ];
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

  getCount = sound: if sound ? count then sound.count else 1;

  square = f: d: vol: overlay [
    (sine f d vol)
    (sine (f*3.0) d (vol / 3.0))
    (sine (f*5.0) d (vol / 5.0))
    (sine (f*7.0) d (vol / 7.0))
    (sine (f*9.0) d (vol / 9.0))
    (sine (f*11.0) d (vol / 11.0))
    (sine (f*13.0) d (vol / 13.0))
  ];

  chord = notes: duration: volume:
    overlay (pkgs.lib.lists.map
        (frequency: sine frequency duration volume)
        notes);

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

  sequence = lib.fold binarySeq (sine 14000 0.1 0.0);

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

  overlay = lib.fold binaryOverlay (sine 14000 0.1 0.0);
}
