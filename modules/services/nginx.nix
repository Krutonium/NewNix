{ self, ... }:
{
  flake.nixosModules.nginx =
    { config, ... }:
    {
      users.groups.anubis-access = { };
      users.users.nginx.extraGroups = [ "anubis-access" ];
      networking.firewall.allowedTCPPorts = [
        80
        443
      ];
      systemd.services.nginx.serviceConfig.ReadWritePaths = [ "/persist/live/" ];
      security.acme = {
        defaults = {
          renewInterval = "daily";
          email = "PFCKrutonium@gmail.com";
        };
        acceptTerms = true;
      };
      services.nginx = {
        enable = true;
        recommendedTlsSettings = true;
        recommendedOptimisation = true;
        recommendedGzipSettings = true;
        recommendedProxySettings = true;
        clientMaxBodySize = "0";
        appendHttpConfig = ''
          #limit_req_zone $binary_remote_addr zone=git_zone:10m rate=40r/s;
          deny 47.80.0.0/13;
          deny 47.74.0.0/15;
          deny 47.76.0.0/14;
          deny 2a03:2880::/32;
        '';
        eventsConfig = ''
          worker_connections 512;
        '';
      };
    };
}
