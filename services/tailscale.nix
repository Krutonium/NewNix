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
    systemd.services.tailscaleConnect = {
      description = "Connects to TailScale";
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      path = [ pkgs.tailscale ];
      script = ''
        tailscale up --advertise-exit-node
      '';
      enable = !cfg.tailscaleUseExitNode;
    };
  };
}
