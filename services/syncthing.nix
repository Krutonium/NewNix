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
  config = mkIf (cfg.syncthing == true) {
    networking.firewall.allowedTCPPorts = [
      8384
      22000
    ];
    networking.firewall.allowedUDPPorts = [
      22000
      21027
    ];
    services = {
      syncthing = {
        enable = true;
        user = "krutonium";
        dataDir = "/home/krutonium/SyncThing"; # Default folder for new synced folders
        configDir = "/home/krutonium/.config/syncthing"; # Folder for Syncthing's settings and keys
      };
    };
  };
}
