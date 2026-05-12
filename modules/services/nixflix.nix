{ inputs, ... }:
{
  flake.nixosModules.nixflix =
    { config, ... }:
    {
      imports = [ inputs.nixflix.nixosModules.default ];
      sops.secrets = {
        sonarr_apikey = {
          owner = "sonarr";
          group = "sonarr";
          mode = "0400";
        };
        sonarr_password = {
          owner = "sonarr";
          group = "sonarr";
          mode = "0400";
        };
        radarr_apikey = {
          owner = "radaar";
          group = "radarr";
          mode = "0400";
        };
        radarr_password = {
          owner = "radaar";
          group = "radaar";
          mode = "0400";
        };
        prowlarr_apikey = {
          owner = "prowlarr";
          group = "prowlarr";
          mode = "0400";
        };
        prowlarr_password = {
          owner = "prowlarr";
          group = "prowlarr";
          mode = "0400";
        };
      };
      nginx = {
        virtualHosts = {
          "sonarr.${config.networking.domain}" = {
            forceSSL = true;
            enableACME = true;
            locations."/".proxyPass = "http://127.0.0.1:8989";
            locations."/robots.txt" = {
              extraConfig = ''
                rewrite ^/(.*)  $1;
                return 200 "User-agent: *\nDisallow: /";
              '';
            };
          };
          "radarr.${config.networking.domain}" = {
            forceSSL = true;
            enableACME = true;
            locations."/".proxyPass = "http://127.0.0.1:7878";
            locations."/robots.txt" = {
              extraConfig = ''
                rewrite ^/(.*)  $1;
                return 200 "User-agent: *\nDisallow: /";
              '';
            };
          };
          "prowlarr.${config.networking.domain}" = {
            forceSSL = true;
            enableACME = true;
            locations."/".proxyPass = "http://127.0.0.1:9696";
            locations."/robots.txt" = {
              extraConfig = ''
                rewrite ^/(.*)  $1;
                return 200 "User-agent: *\nDisallow: /";
              '';
            };
          };
        };
      };
      nixflix = {
        enable = true;
        mediaDir = "/media2/";
        stateDir = "/media2/.nixflix_state";
        nginx = {
          enable = true;
          addHostsEntries = false;
        };
        postgres.enable = true;
        sonarr = {
          enable = true;
          config = {
            apiKey = config.sops.secrets.sonarr_apikey.path;
            hostConfig.password = config.sops.secrets.sonarr_password.path;
          };
        };
        radarr = {
          enable = true;
          config = {
            apiKey = config.sops.secrets.radarr_apikey.path;
            hostConfig.password = config.sops.secrets.radarr_password.path;
          };
        };
        prowlarr = {
          enable = true;
          config = {
            apiKey = config.sops.secrets.prowlarr_apikey.path;
            hostConfig.password = config.sops.secrets.prowlarr_password.path;
          };
        };
      };
    };
}
