{ ... }:
{
  imports = [
    ./wan.nix
    ./lan.nix
    ./bridge.nix
    ./nat.nix
    ./networkd.nix
  ];
}