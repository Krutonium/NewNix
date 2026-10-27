{ config, ... }:
{
  flake.nixosModules.fileHosting =
    { config, ... }:
    {
      sys.nginxAuth.sites = {
        "gryphon.${config.networking.domain}" = [ "krutonium" "gryphon" ];
        "nevvy.${config.networking.domain}" = [ "krutonium" "nevvy" ];
        "scr.${config.networking.domain}" = [ "krutonium" ];
      };
      services.nginx.virtualHosts = {
        "dl.${config.networking.domain}" = {
          forceSSL = true;
          useACMEHost = "krutonium.ca";
          root = "/media2/fileHost";
        };
        "gryphon.${config.networking.domain}" = {
          forceSSL = true;
          useACMEHost = "krutonium.ca";
          root = "/media2/fileHost/gryphon";
          locations = {
            "/" = {
              extraConfig = ''
                autoindex on;
                autoindex_localtime on;
                autoindex_exact_size off;
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
        "nevvy.${config.networking.domain}" = {
          forceSSL = true;
          useACMEHost = "krutonium.ca";
          root = "/media2/fileHost/nevvy";
          locations = {
            "/" = {
              extraConfig = ''
                autoindex on;
                autoindex_localtime on;
                autoindex_exact_size off;
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
        "scr.${config.networking.domain}" = {
          forceSSL = true;
          useACMEHost = "krutonium.ca";
          root = "/media2/screenshots";
          locations = {
            "/" = {
              extraConfig = ''
                autoindex on;
                autoindex_localtime on;
                autoindex_exact_size off;
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
      };
    };
}
