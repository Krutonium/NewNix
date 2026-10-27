{ self, ... }:
{
  flake.nixosModules.nextcloud =
    { config, mv, ... }:
    {
      disabledModules = [ "services/web-apps/nextcloud.nix" ];

      imports = [
        self.nixosModules.postgresql
        "${toString mv.tip.path}/nixos/modules/services/web-apps/nextcloud.nix"
      ];

      services = {
        nginx.virtualHosts = {
          "nextcloud.${config.networking.domain}" = {
            forceSSL = true;
            useACMEHost = "krutonium.ca";
            locations."/robots.txt" = {
              extraConfig = ''
                rewrite ^/(.*)  $1;
                return 200 "User-agent: *\nDisallow: /";
              '';
            };
          };
        };
        nextcloud = {
          enable = true;
          https = true;
          enableImagemagick = true;
          configureRedis = true;
          maxUploadSize = "10240M";
          hostName = "nextcloud.${config.networking.domain}";
          package = mv.tip.nextcloud35;
          home = "/media2/nextcloud";
          settings.log_type = "file";
          config = {
            dbuser = "nextcloud";
            dbpassFile = config.sops.secrets.nextcloud_db_password.path;
            dbtype = "pgsql";
            #dbport = "5432";
            dbname = "nextcloud";
            dbhost = "127.0.0.1:5432";
          };
          phpOptions = {
            "opcache.interned_strings_buffer" = "50";
          };
        };
      };

      systemd.services.nextcloud-setup = {
        after = [ "postgresql.target" ];
        requires = [ "postgresql.target" ];
      };
    };
}
