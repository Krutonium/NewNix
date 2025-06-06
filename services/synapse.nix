{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with builtins;
let
  cfg = config.sys.services;
in
{
  config = mkIf (cfg.synapse == true) {
    sys.services.postgresql = true;
    services = {
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
          listeners = [
            {
              port = 8008;
              bind_addresses = [
                "127.0.0.1"
                "::1"
              ]; # only local, handled by nginx reverse-proxy
              type = "http";
              tls = false;
              x_forwarded = true;
              resources = [
                {
                  names = [
                    "client"
                    "federation"
                  ];
                  compress = false;
                }
              ];
            }
          ];
        };
      };
    };
  };
}
