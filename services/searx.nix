{
  config,
  lib,
  ...
}:
with lib;
with builtins;
let
  cfg = config.sys.services;
in
{
  config = mkIf (cfg.searx == true) {
    networking.firewall.allowedTCPPorts = [ 631 ];
    services.searx = {
      enable = true;
      redisCreateLocally = true;
      settings = {
        server = {
          port = 60613;
          bind_address = "127.0.0.1";
          base_url = "https://search.krutonium.ca";
        };
      };
    };
  };
}
