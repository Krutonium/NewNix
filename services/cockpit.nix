{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.services;
  ports = 9090;
in
{
  config = mkIf (cfg.cockpit == true) {
    services.cockpit = {
      enable = true;
      port = ports;
    };
    networking.firewall.interfaces."bridge".allowedTCPPorts = [ ports ];
  };
}
