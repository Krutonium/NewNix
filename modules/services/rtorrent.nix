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
            protocol.encryption.set = allow_incoming,try_outgoing,enable_retry
            throttle.max_uploads.set = 0
            throttle.max_uploads.global.set = 1000
            throttle.min_peers.normal.set = 1000
            throttle.max_peers.normal.set = 1000
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
        basicAuthFile = config.sops.secrets.basicAuth.path;
      };
      users.users.krutonium.extraGroups = [ "rtorrent" ];
      systemd.tmpfiles.rules = [
        "d /media2/rTorrent/downloads 0775 rtorrent rtorrent -"
        "d /media2/rTorrent/data      0775 rtorrent rtorrent -"
      ];
    };
}
