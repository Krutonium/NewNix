{ ... }:
{
  nixpkgs.overlays = [
    (import ./nvidia.nix)
  ];
}
