{ ... }:
{
  nixpkgs.overlays = [
    (import ./nvidia.nix)
    (import ./zed.nix)
  ];
}
