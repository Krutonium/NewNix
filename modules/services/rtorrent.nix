{ ... }:
{
  flake.nixosModules.rtorrent =
    { config, pkgs, ... }:
    let
      peerPort = 51412;
      web-port = 8112;
    in
    {
      services = {
        rtorrent = {
          enable = true;
          openFirewall = true;
          port = peerPort;
        };
        flood = {
          enable = true;
          port = web-port;
          extraArgs = [ "--rtsocket=${config.services.rtorrent.rpcSocket}" ];
        };
        nginx.virtualHosts = {
          "flood.${config.networking.domain}" = {
            forceSSL = true;
            enableACME = true;
            locations."/".proxyPass = "http://127.0.0.1:${web-port}";
            locations."/robots.txt" = {
              extraConfig = ''
                rewrite ^/(.*)  $1;
                return 200 "User-agent: *\nDisallow: /";
              '';
            };
          };
        };
      };

      systemd.services = {
        rtorrent.serviceConfig.LimitNOFILE = 16384;
        flood.serviceConfig.SupplementaryGroups = [ config.services.rtorrent.group ];
      };
    };
}
