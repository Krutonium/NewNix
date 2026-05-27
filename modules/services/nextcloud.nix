{ self, ... }:
{
  flake.nixosModules.nextcloud =
    { pkgs, config, ... }:
    {
      imports = [
        self.nixosModules.postgresql
      ];
      services = {
        nginx.virtualHosts = {
          "nextcloud.${config.networking.domain}" = {
            forceSSL = true;
            enableACME = true;
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
          package = pkgs.nextcloud33;
          home = "/media2/nextcloud";
          settings.log_type = "file";
          config = {
            adminpassFile = "/persist/nextcloud-admin-pass";
            adminuser = "root";

            dbuser = "nextcloud";
            dbpassFile = "/persist/nextcloud-db-pass";
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
    };
}
