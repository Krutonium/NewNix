{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.services;
in
{
  config = mkIf (cfg.nextcloud == true) {
    services = {
      nextcloud = {
        enable = true;
        https = true;
        enableImagemagick = true;
        maxUploadSize = "10240M";
        hostName = "nextcloud.krutonium.ca";
        package = pkgs.nextcloud29;
        home = "/media2/nextcloud";
        config = {
          adminpassFile = "/persist/nextcloud-admin-pass";
          adminuser = "root";
        };
      };
    };
  };
}
