{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with builtins;
let
  cfg = config.sys.services;
in
{
  config = mkIf (cfg.plex == true) {
    #networking.firewall.allowedTCPPorts = [ 32400 ]; Re Enable when https://github.com/NixOS/nixpkgs/issues/433765 is fixed
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
