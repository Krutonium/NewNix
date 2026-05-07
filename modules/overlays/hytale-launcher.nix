{ inputs, ... }:
{
  flake.overlays.hytale-launcher = final: prev: {
    hytale-launcher = inputs.hytale-launcher-nix.packages.x86_64-linux.hytale-launcher;
  };
}