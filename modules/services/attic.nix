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
          allowed-hosts = [ "cache.krutonium.ca" "10.0.0.3" ];
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
    };
}
