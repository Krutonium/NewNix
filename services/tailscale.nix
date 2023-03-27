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
  cfg = mkIf (cfg.tailscaleUseExitNode == true) {
    systemd.services.tailscaleConnect = {
      description = "Connects to TailScale and Routes Traffic";
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      path = [ pkgs.tailscale ];
      script = ''
        tailscale up --exit-node=uwebserver
      '';
      enable = cfg.tailscaleUseExitNode;
    };
  };
}
