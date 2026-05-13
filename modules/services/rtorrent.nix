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
          user = "rtorrent";
          group = "rtorrent";
          dataPermissions = "0755";
          dataDir = "/media2/rTorrent/data";
          downloadDir = "/media2/rTorrent/downloads/";
          configText = ''
            dht.mode.set = disable
            protocol.pex.set = no
            trackers.use_udp.set = no
            protocol.encryption.set = allow_incoming,try_outgoing,enable_retry
            throttle.max_uploads.set = 0
            throttle.max_uploads.global.set = 250
            throttle.min_peers.normal.set = 20
            throttle.max_peers.normal.set = 60
            throttle.min_peers.seed.set = 30
            throttle.max_peers.seed.set = 80
            trackers.numwant.set = 80
          '';
        }; # /run/rtorrent/rpc.sock
        rutorrent = {
          enable = true;
          hostName = "rutorrent.krutonium.ca";
          rpcSocket = config.services.rtorrent.rpcSocket;
          nginx.enable = true;
        };
      };
      services.nginx.virtualHosts.${config.services.rutorrent.hostName} = {
        basicAuthFile = config.sops.secrets.htpasswd.path;
      };
      systemd.tmpfiles.rules = [
        "d /media2/rTorrent/downloads 0775 rtorrent rtorrent -"
        "d /media2/rTorrent/data      0775 rtorrent rtorrent -"
      ];
    };
}
