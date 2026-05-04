# modules/cachyos-kernel-overlay.nix
{ inputs, ... }:
{
  flake.overlays.unstable = final: prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (prev) system;
      config.allowUnfree = true;
    };
  };
}
