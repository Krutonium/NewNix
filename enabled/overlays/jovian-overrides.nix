# modules/overlays/jovian-overrides.nix
{ inputs, ... }:
{
  flake.overlays.jovian-unstable-bits = final: prev: let
    unstable = import inputs.nixpkgs-unstable {
      inherit (prev) system;
      config.allowUnfree = true;
    };
  in {
    inherit (unstable) gamescope steam decky-loader;
  };
}