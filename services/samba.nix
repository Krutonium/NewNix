{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.services;
in
{
  config = mkIf (cfg.samba == true) {
    networking.firewall.allowedTCPPorts = [ 139 445 2049 ];
    networking.firewall.allowedUDPPorts = [ 137 138 ];
    services.samba = {
      enable = true;
      openFirewall = true;
      nsswins = true;

      settings = {
        media = {
          browseable = true;
          "guest ok" = "no";
          path = "/media";
        };
        media2 = {
          browseable = true;
          "guest ok" = "no";
          path = "/media2";
        };
        LinuxIsos = {
          path = "/media2/transmission";
          "guest ok" = "no";
          browseable = true;
        };
        Krutonium = {
          path = "/home/krutonium";
          browseable = true;
          "guest ok" = "no";
        };
      };
    };
  };
}
