{ ... }:
{
  flake.nixosModules.attic =
    { config, ... }:
    {
      services.atticd = {
        enable = true;
        credentialsFile = config.sops.secrets."attic/credentials".path;
        settings = {
          listen = "127.0.0.1:8080";
          allowed-hosts = [ "cache.krutonium.ca" ];
          api-endpoint = "https://cache.krutonium.ca/";
          storage = {
            type = "local";
            path = "/attic";
          };
          chunking = {
            nar-size-threshold = 65536;
            min-size = 16384;
            avg-size = 131072;
            max-size = 1048576;
          };
        };
      };
      services.nginx.virtualHosts."cache.krutonium.ca" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://10.0.0.3:8080";
          extraConfig = ''
            client_max_body_size 0;  # NARs can be large
            proxy_read_timeout 600;  # chunked uploads take time
            proxy_request_buffering off;
          '';
        };
      };
    };
}
