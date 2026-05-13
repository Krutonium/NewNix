{ inputs, ... }:
{
  flake.overlays.dusklight = final: prev: {
    dusklight = inputs.dusklight.packages.x86_64-linux.default;
  };
}
