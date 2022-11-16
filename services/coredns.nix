{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.services;
in
{
  config = mkIf (cfg.coredns == true) {
    services.coredns.enable = true;
    networking.firewall.allowedTCPPorts = [ 53 ];
    networking.firewall.allowedUDPPorts = [ 53 ];
    services.coredns.config =
      ''
        . {
            # Use Cloudflare then Google for requests
            forward . 1.1.1.1 1.0.0.1 8.8.8.8 8.8.4.4
            cache
          }
        }
        log
      '';
  };
}
