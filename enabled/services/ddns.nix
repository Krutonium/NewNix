{ ... }:
{
  flake.nixosModules.ddns =
    { config, ... }:
    {
      sops.secrets.cloudflare_ddns_token = { };
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
        passwordFile = config.sops.secrets.cloudflare_ddns_token.path;
        usev4 = "webv4, webv4=ipv4.icanhazip.com";
        usev6 = "ifv6, ifv6=br0";
      };
    };
}
