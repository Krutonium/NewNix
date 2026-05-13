{ ... }:
{
  flake.nixosModules.rtorrent =
    { config, lib, ... }:
    let
      peerPort = 51412;
      web-port = 8112;
    in
    {
      sops.secrets.basicAuth = {
        owner = "nginx";
        group = "nginx";
        mode = "0440";
      };
      services = {
        rtorrent = {
          enable = true;
          openFirewall = true;
          port = peerPort;
          dataPermissions = "0755";
          dataDir = "/media2/rTorrent/data";
          downloadDir = "/media2/rTorrent/downloads/";
          configText = ''
            dht.mode.set = disable
            protocol.pex.set = no
            trackers.use_udp.set = no
            protocol.encryption.set = allow_incoming,try_outgoing,enable_retry
            network.scgi.open_port = 127.0.0.1:5000
            throttle.max_uploads.set = 0
            throttle.max_uploads.global.set = 250
            throttle.min_peers.normal.set = 20
            throttle.max_peers.normal.set = 60
            throttle.min_peers.seed.set = 30
            throttle.max_peers.seed.set = 80
            trackers.numwant.set = 80
          '';

        }; # /run/rtorrent/rpc.sock
        flood = {
          enable = true;
          port = web-port;
          extraArgs = [
            "--allowedpath"
            "/var/lib/rtorrent"
          ];
        };
        nginx.virtualHosts = {
          "flood.${config.networking.domain}" = {
            forceSSL = true;
            enableACME = true;
            locations."/".proxyPass = "http://127.0.0.1:${toString web-port}";
            basicAuthFile = config.sops.secrets.basicAuth.path;
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
        flood.serviceConfig = {
          SupplementaryGroups = [ config.services.rtorrent.group ];
          User = "flood";
          Group = "rtorrent";
          DynamicUser = lib.mkForce false;
        };
      };
      users.users.flood = {
        isSystemUser = true;
        group = "rtorrent";
      };
    };
}
