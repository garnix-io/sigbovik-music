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

  ipower = x: y:
    if y == 0 then
      1.0
    else if y < 0 then
      1.0 / (ipower x (y * -1))
    else
      1.0 * x * (ipower x (y - 1));

  midiConstant = 1.0594630943592953; # 2.0**(1.0/12.0)
  fromMidi = midi: 440 * (ipower midiConstant (midi - 69));

  sine =
    frequency: duration: vol:
    let seconds = duration / 6; in
    pkgs.runCommand
      "sine-${builtins.toString frequency}-${builtins.toString seconds}.wav"
      {
        nativeBuildInputs = [ pkgs.sox ];
      }
      ''
        sox -V -r 48000 -n -b 16 -c 2 $out synth ${builtins.toString seconds} sin ${builtins.toString frequency} vol ${builtins.toString (vol / 100)}
      '';

  getCount = sound: if sound ? count then sound.count else 1;

  square = f: d: vol: overlay [
    (sine f d vol)
    (sine (f * 3.0) d (vol / 3.0))
    (sine (f * 5.0) d (vol / 5.0))
    (sine (f * 7.0) d (vol / 7.0))
    (sine (f * 9.0) d (vol / 9.0))
    (sine (f * 11.0) d (vol / 11.0))
    (sine (f * 13.0) d (vol / 13.0))
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
        env = {
          inherit first second;
        };
      }
      ''
        sox $first $second $out
      '') // { count = sum; };

  sequence = lib.fold binarySeq (sine 14000 0.1 0.0);

  binaryOverlay = first: second:
    let sum = getCount first + getCount second;
    in
    (pkgs.runCommand "overlay-of-${builtins.toString sum}-notes.wav"
      {
        nativeBuildInputs = [ pkgs.ffmpeg ];
        env = {
          inherit first second;
        };
      }
      ''
        ffmpeg -i $first -i $second -filter_complex amix=inputs=2:duration=longest $out
      '') // { count = sum; };

  overlay = lib.fold binaryOverlay (sine 14000 0.1 0.0);
}
