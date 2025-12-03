{ ... }:
{
  nixpkgs.overlays = [
    (import ./nvidia.nix)
    (import ./discord.nix)
    (import ./intel-media-sdk.nix)
  ];
}
