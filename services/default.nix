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
  };
  imports = [ ./plex.nix ];
}