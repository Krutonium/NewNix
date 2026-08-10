# modules/cachyos-kernel-overlay.nix
{ inputs, ... }:
{
  flake.overlays.master = final: prev: {
    master = import inputs.nixpkgs-master {
      inherit (prev) system;
      config.allowUnfree = true;
    };
  };
}
