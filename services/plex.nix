{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.services;
in
{
  config = mkIf (cfg.plex == true) {
    networking.firewall.allowedTCPPorts = [ 32400 ];
    services = {
      plex = {
        enable = true;
        openFirewall = true;
        package = pkgs.master.plex;
      };
      tautulli = {
        enable = true;
        dataDir = "/persist/tautulli/";
        configFile = "/persist/tautulli/config.ini";
        openFirewall = true;
      };
    };
  };
}
