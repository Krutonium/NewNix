{ ... }:
{
  flake.nixosModules.ddns =
    { ... }:
    {
      services.ddclient = {
        enable = true;
        protocol = "cloudflare";
        zone = "krutonium.ca";
        domains = [
          "krutonium.ca"
          "*.krutonium.ca"
          "www.krutonium.ca"
        ];
        username = "token";
        passwordFile = "/persist/cloudflare_ddns";
        usev4 = "webv4, webv4=ipv4.icanhazip.com";
        usev6 = "ifv6, ifv6=br0";
      };
    };
}
