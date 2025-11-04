{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with builtins;
let
  cfg = config.sys.services;
  fqdn = "synapse.${config.networking.domain}";
  baseUrl = "https://${fqdn}";
  clientConfig."m.homeserver".base_url = baseUrl;
  serverConfig."m.server" = "${fqdn}:443";
  mkWellKnown = data: ''
    default_type application/json;
    add_header Access-Control-Allow-Origin *;
    return 200 '${builtins.toJSON data}';
  '';
  pkg = pkgs.nginx.override {
    modules = [
      pkgs.nginxModules.rtmp
    ];
  };

in
{
  config = mkIf (cfg.nginx == true) {
    networking.firewall.allowedTCPPorts = [
      80
      443
      1935 # RTMP
    ];
    sops.secrets."stream_keys" = {
      sopsFile = ../secrets/secrets.yaml;
      key = "stream_keys";
    };

    systemd.tmpfiles.rules = [
      "d /persist/live 0755 nginx nginx"
      "d /persist/live/hls 0755 nginx nginx"
    ];
    systemd.services.nginx.serviceConfig.ReadWritePaths = [ "/persist/live/" ];
    security.acme = {
      defaults = {
        renewInterval = "200h";
        email = "PFCKrutonium@gmail.com";
      };
      acceptTerms = true;
    };
    services.nginx = {
      enable = true;
      package = pkg;
      appendConfig = ''
        rtmp {
         server {
           listen 1935;
           chunk_size 4096;

           application live {
             live on;
             record off;

             # HLS output for browsers
             hls on;
             hls_path /persist/live/hls;
             hls_fragment 3s;
             hls_playlist_length 60s;
             hls_nested on;

             on_publish http://10.0.0.2:8081;
           }
          }
        }
      '';
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
      '';
      eventsConfig = ''
        worker_connections 512;
      '';
      virtualHosts = {
        "vr.krutonium.ca" = {
          root = "/persist/live";
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            index = "index.html";
          };
          locations."/hls/" = {
            extraConfig = ''
              add_header 'Access-Control-Allow-Origin' '*';
              types {
                application/vnd.apple.mpegurl m3u8;
                video/mp2t ts;
              }
            '';
          };
        };
        "map.krutonium.ca" = {
          forceSSL = true;
          enableACME = true;
          root = "/media2/BlueMap";
          locations."/maps" = {
            extraConfig = ''
              gzip_static always;
            '';
          };
          locations."/maps/tiles" = {
            extraConfig = ''
              gzip_static always;
              error_page 404 = @tiles_204;
            '';
          };
        };
        "_" = {
          # This is a default catchall - Like *
          default = true;
          extraConfig = ''
            return 301 https://krutonium.ca;
          '';
        };
        "restream.krutonium.ca" = {
          forceSSL = true;
          enableACME = true;
          locations."/".proxyPass = "http://127.0.0.1:1233";
        };
        "synapse-admin.krutonium.ca" = {
          forceSSL = true;
          enableACME = true;
          root = "${pkgs.synapse-admin}";
        };
        "dl.krutonium.ca" = {
          forceSSL = true;
          enableACME = true;
          root = "/media2/fileHost";
        };
        "gryphon.krutonium.ca" = {
          forceSSL = true;
          enableACME = true;
          root = "/media2/fileHost/gryphon";
          locations = {
            "/" = {
              extraConfig = ''
                autoindex on;
                autoindex_localtime on;
                autoindex_exact_size off;
                auth_basic "Restricted Access";
                auth_basic_user_file /persist/httpAuth;
              '';
            };
            # Disable auth for files with an extension (e.g., .txt, .jpg, .html)
            "~* \\.[a-zA-Z0-9]+$" = {
              extraConfig = ''
                auth_basic off;
              '';
            };
            "/robots.txt" = {
              extraConfig = ''
                rewrite ^/(.*)  $1;
                return 200 "User-agent: *\nDisallow: /";
              '';
            };
          };
        };
        "scr.krutonium.ca" = {
          forceSSL = true;
          enableACME = true;
          root = "/media2/screenshots";
          locations = {
            "/" = {
              extraConfig = ''
                autoindex on;
                autoindex_localtime on;
                autoindex_exact_size off;
                auth_basic "Restricted Access";
                auth_basic_user_file /persist/httpAuth;
              '';
            };
            # Disable auth for files with an extension (e.g., .txt, .jpg, .html)
            "~* \\.[a-zA-Z0-9]+$" = {
              extraConfig = ''
                auth_basic off;
              '';
            };
          };
        };
        "krutonium.ca" = {
          forceSSL = true;
          enableACME = true;
          root = "/var/www/home/";
          serverAliases = [ "www.krutonium.ca" ];
          locations." = /.well-known/matrix/server".extraConfig = mkWellKnown serverConfig;
          locations."= /.well-known/matrix/client".extraConfig = mkWellKnown clientConfig;
          locations."/_matrix".proxyPass = "http://[::1]:8008";
          # Forward requests for e.g. SSO and password-resets.
          locations."/_synapse/client".proxyPass = "http://[::1]:8008";
          locations."/".proxyPass = "http://127.0.0.1:1313"; # Hugo
          locations."/status" = {
            extraConfig = ''
              stub_status on;
              access_log off;
              allow 10.0.0.0/24;
              deny all;
            '';
          };
        };
        "plex.krutonium.ca" = {
          forceSSL = true;
          enableACME = true;
          http2 = true;
          extraConfig = ''
            #Some players don't reopen a socket and playback stops totally instead of resuming after an extended pause
            send_timeout 100m;

            # Why this is important: https://blog.cloudflare.com/ocsp-stapling-how-cloudflare-just-made-ssl-30/
            ssl_stapling on;
            ssl_stapling_verify on;

            ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
            ssl_prefer_server_ciphers on;
            #Intentionally not hardened for security for player support and encryption video streams has a lot of overhead with something like AES-256-GCM-SHA384.
            ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:ECDHE-RSA-DES-CBC3-SHA:ECDHE-ECDSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA';

            # Forward real ip and host to Plex
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header Host $server_addr;
            proxy_set_header Referer $server_addr;
            proxy_set_header Origin $server_addr;

            # Plex has A LOT of javascript, xml and html. This helps a lot, but if it causes playback issues with devices turn it off.
            gzip on;
            gzip_vary on;
            gzip_min_length 1000;
            gzip_proxied any;
            gzip_types text/plain text/css text/xml application/xml text/javascript application/x-javascript image/svg+xml;
            gzip_disable "MSIE [1-6]\.";

            # Nginx default client_max_body_size is 1MB, which breaks Camera Upload feature from the phones.
            # Increasing the limit fixes the issue. Anyhow, if 4K videos are expected to be uploaded, the size might need to be increased even more
            client_max_body_size 100M;

            # Plex headers
            proxy_set_header X-Plex-Client-Identifier $http_x_plex_client_identifier;
            proxy_set_header X-Plex-Device $http_x_plex_device;
            proxy_set_header X-Plex-Device-Name $http_x_plex_device_name;
            proxy_set_header X-Plex-Platform $http_x_plex_platform;
            proxy_set_header X-Plex-Platform-Version $http_x_plex_platform_version;
            proxy_set_header X-Plex-Product $http_x_plex_product;
            proxy_set_header X-Plex-Token $http_x_plex_token;
            proxy_set_header X-Plex-Version $http_x_plex_version;
            proxy_set_header X-Plex-Nocache $http_x_plex_nocache;
            proxy_set_header X-Plex-Provides $http_x_plex_provides;
            proxy_set_header X-Plex-Device-Vendor $http_x_plex_device_vendor;
            proxy_set_header X-Plex-Model $http_x_plex_model;

            # Websockets
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";

            # Buffering off send to the client as soon as the data is received from Plex.
            proxy_redirect off;
            proxy_buffering off;
          '';
          locations."/" = {
            proxyPass = "http://127.0.0.1:32400/";
          };
        };
        "gitea.krutonium.ca" = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            return = "301 https://git.krutonium.ca$request_uri";
          };
        };
        "git.krutonium.ca" = {
          enableACME = true; # Use ACME certs
          forceSSL = true; # Force SSL
          locations."/".proxyPass = "http://127.0.0.1:3001/"; # Proxy Gitea
          locations."/robots.txt" = {
            extraConfig = ''
              rewrite ^/(.*)  $1;
              return 200 "User-agent: *\nDisallow: /";
            '';
          };
          extraConfig = ''
            #limit_req zone=git_zone burst=20 nodelay;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header Host $server_addr;
            proxy_set_header Referer $server_addr;
            proxy_set_header Origin $server_addr;

          '';
        };
        "nextcloud.krutonium.ca" = {
          forceSSL = true;
          enableACME = true;
          locations."/robots.txt" = {
            extraConfig = ''
              rewrite ^/(.*)  $1;
              return 200 "User-agent: *\nDisallow: /";
            '';
          };
        };
        "synapse.krutonium.ca" = {
          forceSSL = true;
          enableACME = true;
          locations."/".proxyPass = "http://127.0.0.1:8008";
          locations."/robots.txt" = {
            extraConfig = ''
              rewrite ^/(.*)  $1;
              return 200 "User-agent: *\nDisallow: /";
            '';
          };
        };
        "torrent.krutonium.ca" = {
          forceSSL = true;
          enableACME = true;
          locations."/".proxyPass = "http://127.0.0.1:8112";
          locations."/robots.txt" = {
            extraConfig = ''
              rewrite ^/(.*)  $1;
              return 200 "User-agent: *\nDisallow: /";
            '';
          };
        };
        "search.krutonium.ca" = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyWebsockets = true;
            proxyPass = "http://127.0.0.1:60613";
          };
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
          '';
        };
      };
    };
  };
}
