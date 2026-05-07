{ ... }:
{
  flake.nixosModules.forgejo =
    { pkgs, config, ... }:
    {
      services.forgejo = {
        enable = true;
        package = pkgs.unstable.forgejo;
        stateDir = "/media2/forgejo/repos";
        settings = {
          server = {
            ROOT_URL = "https://git.${config.networking.domain}/";
            HTTP_PORT = 3001;
            DOMAIN = "git.${config.networking.domain}";
          };
          "attachment" = {
            MAX_SIZE = 1000;
          };
          "git.timeout" = {
            DEFAULT = 720;
            MIGRATE = 30000;
            MIRROR = 72000;
            CLONE = 30000;
            PULL = 30000;
            GC = 60;
          };
          service = {
            DISABLE_REGISTRATION = true;
          };
          indexer = {
            REPO_INDEXER_ENABLED = true;
          };
          DEFAULT = {
            APP_NAME = "Krutonium's Forgejo";
          };
          Federation = {
            Enabled = true;
          };
        };
        database = {
          type = "sqlite3";
          user = "gitea";
          name = "gitea";
        };
      };
      services.anubis.instances = {
        forgejo = {
          enable = true;
          group = "anubis-access";
          settings = {
            # How hard the proof-of-work challenge is (higher = harder for bots)
            DIFFICULTY = 5;
            # Where Anubis forwards legitimate traffic
            TARGET = "http://127.0.0.1:3001";
            # Where to point NGINX
            BIND = "/run/anubis/anubis-forgejo/anubis.sock";
            # Where to send Statistics
            METRICS_BIND = "/run/anubis/anubis-forgejo/anubis-metrics.sock";
            SERVE_ROBOTS_TXT = true;
          };
        };
      };
      services.nginx.virtualHosts = {
        "gitea.${config.networking.domain}" = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            return = "301 https://git.${config.networking.domain}$request_uri";
          };
        };
        "git.${config.networking.domain}" = {
          enableACME = true; # Use ACME certs
          forceSSL = true; # Force SSL
          locations."/".proxyPass = "http://unix:/run/anubis/anubis-forgejo/anubis.sock:/"; # Proxy Gitea
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
      };
    };
}
