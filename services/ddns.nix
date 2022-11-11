{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.services;
in
{
  config = mkIf (cfg.ddns == true) {
    services.ddclient = {
      enable = true;
      protocol = "namecheap";
      username = "krutonium.ca";
      domains = [ "*" "@" ];
      ipv6 = true;
      passwordFile = "/persist/ddclient.auth";
    };
  };
}
