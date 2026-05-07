{ ... }:
{
  flake.nixosModules.ddns =
    { config, ... }:
    {
      services.ddclient = {
        enable = true;
        protocol = "cloudflare";
        zone = config.networking.domain;
        domains = [
          "${config.networking.domain}"
          "*.${config.networking.domain}"
          "www.${config.networking.domain}"
        ];
        username = "token";
        passwordFile = "/persist/cloudflare_ddns";
        usev4 = "webv4, webv4=ipv4.icanhazip.com";
        usev6 = "ifv6, ifv6=br0";
      };
    };
}
