{ inputs, ... }:
{
  flake.overlays.hanabi = final: prev: {
    gnome-ext-hanabi = inputs.hanabi-src.packages.${final.stdenv.hostPlatform.system}.default;
  };
}