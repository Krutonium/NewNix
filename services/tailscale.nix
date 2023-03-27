{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.services;
in
{
  config = mkIf (cfg.tailscale == true) {
    services.tailscale.enable = true;
    networking.firewall = {
      checkReversePath = "loose";
      trustedInterfaces = [ "tailscale0" ];
      allowedUDPPorts = [ config.services.tailscale.port ];
    };
  };
}
