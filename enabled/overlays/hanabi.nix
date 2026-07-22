{ inputs, ... }:
{
  flake.overlays.hanabi = final: prev: {
    gnomeExtensions = prev.gnomeExtensions // {
      gnome-ext-hanabi = inputs.hanabi-src.packages.${final.stdenv.hostPlatform.system}.default;
    };
  };
}