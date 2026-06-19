{ self, ... }:
{
  flake.nixosModules.nginx =
    { lib, config, ... }:
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
        certs = {
          "krutonium.ca" = {
            domain = "*.krutonium.ca";
            extraDomainNames = lib.mkForce [ "*.krutonium.ca" ];
            group = "nginx";
            dnsProvider = "cloudflare";
            environmentFile = "/persist/cloudflare_ddns_env";
            webroot = lib.mkForce null;
          };
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
        # This has to go here because nginx is on uWebServer while Attic is on uServerHost
        virtualHosts."cache.krutonium.ca" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://10.0.0.3:8080";
            extraConfig = ''
              client_max_body_size 0;  # NARs can be large
              keepalive_timeout 600;
              keepalive_requests 10000;
              proxy_read_timeout 600;  # chunked uploads take time
              proxy_request_buffering off;
              proxy_buffering off;
              proxy_send_timeout 600;
              proxy_connect_timeout 30;
              proxy_http_version 1.1;
              proxy_set_header Connection "";
              proxy_force_ranges on;
            '';
          };
        };
      };
    };
}
