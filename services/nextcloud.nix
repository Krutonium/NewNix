{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.services;
in
{
  config = mkIf (cfg.nextcloud == true) {
    sys.services.postgresql = true;
    services = {
      nextcloud = {
        enable = true;
        https = true;
        enableImagemagick = true;
        maxUploadSize = "10240M";
        hostName = "nextcloud.krutonium.ca";
        package = pkgs.nextcloud29;
        home = "/media2/nextcloud";
        logType = "file";
        config = {
          adminpassFile = "/persist/nextcloud-admin-pass";
          adminuser = "root";

          dbuser = "nextcloud";
          dbpassFile = pkgs.writeText "nextcloud-db-pass" "nextcloud";
          dbtype = "pgsql";
          dbport = "5432";
          dbname = "nextcloud";
          dbhost = "127.0.0.1";
        };
      };
    };
  };
}
