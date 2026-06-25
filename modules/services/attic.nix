{ ... }:
{
  flake.nixosModules.attic =
    { config, ... }:
    let
      user = "atticd";
    in
    {
      users.users.${user} = {
        isSystemUser = true;
        group = "atticd";
      };
      users.groups.atticd = { };
      sops.secrets.atticsecret = {
        owner = user;
      };
      networking.firewall.allowedTCPPorts = [ 8080 ];
      services.atticd = {
        enable = true;
        environmentFile = config.sops.secrets.atticsecret.path;
        user = user;
        settings = {
          listen = "0.0.0.0:8080";
          allowed-hosts = [
            "cache.krutonium.ca"
            "10.0.0.3"
          ];
          api-endpoint = "https://cache.krutonium.ca/";
          storage = {
            type = "local";
            path = "/attic";
          };
          chunking = {
            nar-size-threshold = 65536;
            min-size = 1024 * 2; #2MB
            avg-size = 1024 * 8; #8MB
            max-size = 1204 * 50; #50MB
          };
          garbage-collection = {
            interval = "12 hours";
            default-retention-period = "1 month";
          };
        };
      };
    };
}
