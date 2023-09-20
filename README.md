# SIGBOVIK-esque Nix Music project

Nix library for sequencing music incrementally built from derivations of individual tones.

The library is presented as a Nix module of functions in [sine.nix](./sine.nix).

## Example

[flake.nix](./flake.nix) has packages with an example composition.

Run `nix run github:garnix-io/sigbovik-music` to hear the example.

**NB**: While this repo is private, this requires setting up a github `access-token` in your Nix configuration.
