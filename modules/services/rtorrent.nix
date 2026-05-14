{ ... }:
{
  flake.nixosModules.rtorrent =
    { config, lib, pkgs, ... }:
    let
      peerPort = 51412;
      web-port = 8112;
      apiPort = 1234;
    in
    {
      sops.secrets.basicAuth = {
        owner = "nginx";
        group = "nginx";
        mode = "0440";
      };
      sops.secrets.autobrr_secret = {
        mode = "0770";
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
            throttle.max_uploads.set = 100
            throttle.max_uploads.global.set = 1000
            throttle.min_peers.normal.set = 1000
            throttle.max_peers.normal.set = 1000
            network.bind_address.set = 0.0.0.0
          '';
        }; # /run/rtorrent/rpc.sock
        rutorrent = {
          enable = true;
          hostName = "rutorrent.krutonium.ca";
          rpcSocket = config.services.rtorrent.rpcSocket;
          nginx.enable = true;
        };
        autobrr = {
          enable = true;
          secretFile = config.sops.secrets.autobrr_secret.path;
          settings = {
            checkForUpdates = false;
            host = "10.0.0.1";
            port = "7474";
          };
        };
      };
      services.nginx.virtualHosts.${config.services.rutorrent.hostName} = {
        basicAuthFile = config.sops.secrets.basicAuth.path;
      };
      systemd.services = {
        rtorrent = {
          after = [ "media2.mount" ];
          requires = [ "media2.mount" ];
        };
        rtorrent-scgi-bridge = {
          description = "rTorrent SCGI Unix socket to TCP bridge (socat)";
          after = [ "rtorrent.service" ];
          requires = [ "rtorrent.service" ];

          serviceConfig = {
            ExecStart = ''
              ${pkgs.socat}/bin/socat \
                TCP-LISTEN:${toString apiPort},bind=127.0.0.1,reuseaddr,fork \
                UNIX-CONNECT:${config.services.rtorrent.rpcSocket}
            '';

            Restart = "always";
            RestartSec = 2;

            # basic hardening (optional but safe)
            NoNewPrivileges = true;
            PrivateTmp = true;
          };

          wantedBy = [ "multi-user.target" ];
        };
      };
      users.users.krutonium.extraGroups = [ "rtorrent" ];
      systemd.tmpfiles.rules = [
        "d /media2/rTorrent/downloads 0775 rtorrent rtorrent -"
        "d /media2/rTorrent/data      0775 rtorrent rtorrent -"
        "Z /media2/rTorrent/data      0775 rtorrent rtorrent -"
      ];
    };
}
