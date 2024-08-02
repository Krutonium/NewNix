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
        configureRedis = true;
        maxUploadSize = "10240M";
        hostName = "nextcloud.krutonium.ca";
        package = pkgs.unstable.nextcloud29;
        home = "/media2/nextcloud";
        settings.log_type = "file";
        config = {
          adminpassFile = "/persist/nextcloud-admin-pass";
          adminuser = "root";

          dbuser = "nextcloud";
          dbpassFile = "/persist/nextcloud-db-pass";
          dbtype = "pgsql";
          #dbport = "5432";
          dbname = "nextcloud";
          dbhost = "127.0.0.1:5432";
        };
        phpOptions = {
          "opcache.interned_strings_buffer" = "50";
        };
      };
    };
  };
}
