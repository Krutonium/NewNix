{ inputs, ... }:
{
  flake.overlays.InternetRadio2Computercraft = final: prev: {
    InternetRadio2Computercraft = inputs.InternetRadio2Computercraft.packages.${prev.system}.default;
  };
}