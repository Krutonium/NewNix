{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.services;
in
{
  config = mkIf (cfg.ssh == true) {
    networking.firewall.allowedTCPPorts = [ 22 ];
    networking.firewall.allowedUDPPortRanges = [{ from = 60000; to = 61000; }];
    services.openssh = {
      enable = true;
      permitRootLogin = "yes";
      passwordAuthentication = false;
      ports = [ 22 ];
      forwardX11 = true;
    };
    services.sshguard = {
      enable = cfg.sshGuard;
      whitelist = [ "192.168.0.0/16" ]; # whitelist your local network
    };
    programs.mosh.enable = true;
  };
}
