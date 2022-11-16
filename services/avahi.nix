{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.services;
in
{
  config = mkIf (cfg.avahi == true) {
    networking.firewall.allowedTCPPorts = [ 631 ];
    services.avahi = {
      enable = true;
      publish = {
        enable = true;
        addresses = true;
        workstation = true;
        domain = true;
        hinfo = true;
        userServices = true;
      };
    };
  };
}
