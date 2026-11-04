{ ... }:
{
  flake.nixosModules.rtorrent =
    {
      config,
      mv,
      pkgs,
      ...
    }:
    let
      peerPort = 51412;
      apiPort = 1234;
    in
    {
      disabledModules = [ "services/torrent/rtorrent.nix" ];

      # ...for the one that actually matches mv.tip.rtorrent's version.
      imports = [
        "${toString mv.tip.path}/nixos/modules/services/torrent/rtorrent.nix"
      ];

      sys.nginxAuth.sites.${config.services.rutorrent.hostName} = [ "krutonium" ];

      sops.secrets.autobrr_secret = {
        mode = "0770";
      };
      services = {
        rtorrent = {
          enable = true;
          openFirewall = true;
          port = peerPort;
          package = mv.tip.rtorrent;
          user = "rtorrent";
          group = "rtorrent";
          dataPermissions = "0755";
          dataDir = "/media2/rTorrent/data";
          downloadDir = "/media2/rTorrent/downloads/";
          configText = ''
            protocol.encryption.set = allow_incoming,try_outgoing,enable_retry
            protocol.pex.set = yes

            throttle.max_uploads.set = 100
            throttle.max_uploads.global.set = 1000

            throttle.min_peers.normal.set = 200
            throttle.max_peers.normal.set = 400
            throttle.min_peers.seed.set = 200;
            throttle.max_peers.seed.set = 400;

            trackers.numwant.set = 200;
            trackers.use_udp.set = yes;

            # Trackerless magnets need DHT. rTorrent still excludes torrents
            # marked private from DHT and PEX, so private trackers are safe.
            dht.mode.set = auto;

            network.bind_address.set = 0.0.0.0
          '';
        }; # /run/rtorrent/rpc.sock
        rutorrent = {
          enable = true;
          hostName = "rutorrent.krutonium.ca";
          rpcSocket = config.services.rtorrent.rpcSocket;
          nginx.enable = true;
          plugins = [
            "httprpc"
            "_getdir"
            "_task"
            "autotools"
            "bulk_magnet"
            "check_port"
            "cpuload"
            "datadir"
            "diskspace"
            "edit"
            "erasedata"
            "filedrop"
            "history"
            "mediainfo"
            "ratio"
            "retrackers"
            "screenshots"
            "seedingtime"
            "source"
            "theme"
            "trafic"
            "unpack"
          ];
        };
        autobrr = {
          enable = false;
          secretFile = config.sops.secrets.autobrr_secret.path;
          settings = {
            checkForUpdates = false;
            host = "10.0.0.1";
            port = 7474;
          };
        };
        # FileDrop allows 5 MB per file; PHP's 2 MB default would reject it.
        phpfpm.pools.rutorrent.settings = {
          "php_admin_value[upload_max_filesize]" = "32M";
          "php_admin_value[post_max_size]" = "32M";
        };
      };
      services.nginx.virtualHosts.${config.services.rutorrent.hostName} = {
        forceSSL = true;
        useACMEHost = "krutonium.ca";
        # Allow FileDrop / .torrent uploads larger than nginx's 1 MB default.
        extraConfig = ''
          client_max_body_size 32m;
        '';
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
      users.users.rtorrent.uid = 990;
      users.groups.rtorrent.gid = 990;
      users.users.krutonium.extraGroups = [ "rtorrent" ];
      systemd.tmpfiles.rules = [
        "d /media2/rTorrent/downloads 0775 rtorrent rtorrent -"
        "d /media2/rTorrent/data      0775 rtorrent rtorrent -"
        "Z /media2/rTorrent/data      0775 rtorrent rtorrent -"
      ];
    };
}
