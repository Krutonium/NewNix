{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.services;
in
{
  config = mkIf (cfg.plex == true) {
    networking.firewall.allowedTCPPorts = [ 32400 ];
    services.plex = {
      enable = true;
      openFirewall = true;
    };
  };
}
