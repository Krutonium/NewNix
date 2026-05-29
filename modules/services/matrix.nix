{ self, ... }:
{
  flake.nixosModules.matrix =
    { config, pkgs, ... }:
    let
      fqdn = "synapse.${config.networking.domain}";
      baseUrl = "https://${fqdn}";
      clientConfig."m.homeserver".base_url = baseUrl;
      serverConfig."m.server" = "${fqdn}:443";
      mkWellKnown = data: ''
        default_type application/json;
        add_header Access-Control-Allow-Origin *;
        return 200 '${builtins.toJSON data}';
      '';
    in
    {
      imports = [
        self.nixosModules.postgresql
      ];
      services.nginx.virtualHosts = {
        "synapse-admin.${config.networking.domain}" = {
          forceSSL = true;
          enableACME = true;
          root = "${pkgs.synapse-admin}";
        };
        "synapse.${config.networking.domain}" = {
          forceSSL = true;
          enableACME = true;
          locations."/".proxyPass = "http://127.0.0.1:8008";
          locations."/robots.txt" = {
            extraConfig = ''
              rewrite ^/(.*)  $1;
              return 200 "User-agent: *\nDisallow: /";
            '';
          };
        };
      };
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
          server_name = config.networking.domain;
          enable_registration = false;
          max_upload_size = "10M";
          turn_uris = [
            "stun:stun.l.google.com:19302"
            "stun:stun1.l.google.com:19302"
            "stun:stun2.l.google.com:19302"
            "stun:stun3.l.google.com:19302"
            "stun:stun4.l.google.com:19302"
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
      services.nginx.virtualHosts = {
        # This stays here because of existing machinery that I don't want to move yet.
        "${config.networking.domain}" = {
          forceSSL = true;
          enableACME = true;
          root = "/var/www/home/";
          serverAliases = [ "www.${config.networking.domain}" ];
          locations."= /.well-known/matrix/server".extraConfig = mkWellKnown serverConfig;
          locations."= /.well-known/matrix/client".extraConfig = mkWellKnown clientConfig;
          locations."/_matrix".proxyPass = "http://[::1]:8008";
          # Forward requests for e.g. SSO and password-resets.
          locations."/_synapse/client".proxyPass = "http://[::1]:8008";
          locations."/status" = {
            extraConfig = ''
              stub_status on;
              access_log off;
              allow 10.0.0.0/24;
              deny all;
            '';
          };
        };
      };
    };
}
