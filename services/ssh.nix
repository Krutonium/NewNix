{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.services;
in
{
  config = mkIf (cfg.ssh == true) {
    networking.firewall.allowedTCPPorts = [ 22 ];
    services.openssh = {
      enable = true;
      permitRootLogin = "yes";
      passwordAuthentication = false;
      ports = [22];
      forwardX11 = true;
    };
    services.sshguard = {
      enable = cfg.sshguard;
      whitelist = [ "192.168.0.0/16" ]; # whitelist your local network
    };
  };
}