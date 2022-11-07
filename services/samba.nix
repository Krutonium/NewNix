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
      syncPasswordsByPam = true;
      # run $ sudo smbpasswd -a <username>
      extraConfig = ''
        browsable = yes
        read only = no
      '';
      shares = {
        media = {
          path = "/media";
          browsable = true;
        };
        share = {
          path = "/home/krutonium/share";
          browsable = true;
        };
        LinuxIsos = {
          path = "/transmission";
          browsable = true;
        };
      };
    };
  };
}