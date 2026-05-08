{ inputs, ... }:
{
  flake.overlays.simple-cpu-governor = final: prev: {
    simple-cpu-governor = inputs.simple-cpu-governor.nixosModules.default;
  };
}