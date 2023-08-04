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
      extraConfig = ''
        browsable = yes
        read only = no
      '';
      shares = {
        media = {
          path = "/media";
          browsable = true;
        };
        media2 = {
          path = "/media2";
          browsable = true;
        };
        share = {
          path = "/home/krutonium/share";
          browsable = true;
        };
        LinuxIsos = {
          path = "/media2/transmission";
          browsable = true;
        };
        Krutonium = {
          path = "/home/krutonium";
          browseable = true;
        };
      };
    };
  };
}
