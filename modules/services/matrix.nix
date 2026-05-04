{ self, ... }:
{
  flake.nixosModules.matrix =
    { config, ... }:
    {
      imports = [
        self.nixosModules.postgresql
      ];
      sops.secrets.synapse_turn_shared_secret = {
        owner = "matrix-synapse";
        restartUnits = [ "matrix-synapse.service" ];
      };
      services.matrix-synapse = {
        enable = true;
        dataDir = "/persist/matrix-data";
        extraConfigFiles = [ config.sops.secrets.synapse_turn_shared_secret.path ];
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
          listeners = [
            {
              port = 8008;
              bind_addresses = [
                "127.0.0.1"
                "::1"
              ];
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
}
