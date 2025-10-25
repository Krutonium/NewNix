{ ... }:
{
  nixpkgs.overlays = [
    (import ./nvidia.nix)
    (import ./discord.nix)
  ];
}
