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
      ports = [ 22 ];
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        X11Forwarding = true;
        Ciphers = [ 
          "hmac-sha2-512"
          "hmac-sha2-256"
          "umac-128@openssh.com"
          "chacha20-poly1305@openssh.com"
          "aes256-gcm@openssh.com"
          "aes128-gcm@openssh.com"
          "aes256-ctr"
          "aes192-ctr"
          "aes128-ctr"
        ];
      };
      extraConfig = ''
      Match Address  10.0.0.*
          PermitRootLogin yes
      '';
    };
    services.sshguard = {
      enable = cfg.sshGuard;
      whitelist = [ "10.0.0.0/16" ]; # whitelist your local network
    };
    programs.mosh.enable = true;
  };
}
