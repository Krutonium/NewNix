{ inputs, ... }:
{
  flake.overlays.dusk = final: prev: {
    dusk = inputs.dusk.packages.x86_64-linux.default;
  };
}