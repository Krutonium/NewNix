{ ... }:
{
  flake.nixosModules.rtorrent =
    { config, lib, ... }:
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
          dataPermissions = "0755";
          dataDir = "/media2/downloads/";
          configText = ''
            dht.mode.set = disable
            protocol.pex.set = no
            trackers.use_udp.set = no
          '';

        }; # /run/rtorrent/rpc.sock
        flood = {
          enable = true;
          port = web-port;
          extraArgs = [ "--rtsocket=${config.services.rtorrent.rpcSocket}" ];
        };
        nginx.virtualHosts = {
          "flood.${config.networking.domain}" = {
            forceSSL = true;
            enableACME = true;
            locations."/".proxyPass = "http://127.0.0.1:${toString web-port}";
            locations."/robots.txt" = {
              extraConfig = ''
                rewrite ^/(.*)  $1;
                return 200 "User-agent: *\nDisallow: /";
                auth_basic "Restricted Access";
                auth_basic_user_file /persist/httpAuth;
              '';
            };
          };
        };
      };

      systemd.services = {
        rtorrent.serviceConfig.LimitNOFILE = 16384;
        flood.serviceConfig = {
          SupplementaryGroups = [ config.services.rtorrent.group ];
          DynamicUser = lib.mkForce false;
        };
      };
    };
}
