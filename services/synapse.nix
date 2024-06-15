{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.services;
  sql_current = pkgs.postgresql_16;
  sql_upgrade = pkgs.postgresql_16;
in
{
  config = mkIf (cfg.synapse == true) {
    sys.services.postgresql = true;
    services = {
      matrix-sliding-sync = {
        createDatabase = true;
        enable = true;
        environmentFile = "4a2982e5c609ecfe245f161faeda9d8dcecc301797340fa71f054621d6aeca35"; 
      };
      matrix-synapse = {
        enable = true;
        dataDir = "/persist/matrix-data";
        settings = {
          database_name = "psycopg2";
          server_name = "krutonium.ca";
          enable_registration = false;
          max_upload_size = "10M";
          turn_uris = [
            "turn:staticauth.openrelay.metered.ca:80"
            "turn:staticauth.openrelay.metered.ca:443"
            "turn:staticauth.openrelay.metered.ca:80?transport=tcp"
            "turn:staticauth.openrelay.metered.ca:443?transport=tcp"
            "turns:staticauth.openrelay.metered.ca:443"
          ];
          turn_shared_secret = "openrelayprojectsecret";
          listeners = [{
            port = 8008;
            bind_addresses = [ "127.0.0.1" "::1" ]; # only local, handled by nginx reverse-proxy
            type = "http";
            tls = false;
            x_forwarded = true;
            resources = [{
              names = [ "client" "federation" ];
              compress = false;
            }];
          }];
        };
      };
    };
  };
}
