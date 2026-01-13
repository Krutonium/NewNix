{ ... }:
{
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };
  imports = [
    ./wan.nix
    ./lan.nix
    ./bridge.nix
    ./nat.nix
    ./networkd.nix
  ];
}
