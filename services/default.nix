{ pkgs, config, lib, ... }:
with lib;
with builtins;
{
  options.sys.services = {
    plex = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Plex Media Server
      '';
    };
    avahi = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Avahi
      '';
    };
    coredns = mkOption {
      type = types.bool;
      default = false;
      description = ''
        CoreDNS
      '';
    };
  };
  imports = [
    ./plex.nix
    ./avahi.nix
    ./coredns.nix
    ./samba.nix
  ];
}