{ ... }:
{
  flake.nixosModules.rtorrent =
    {
      config,
      lib,
      mv,
      pkgs,
      ...
    }:
    let
      peerPort = 51412;
      apiPort = 1234;
      pinned = mv.at (mv.revOf "rtorrent" "0.16.22");
    in
    {
      disabledModules = [ "services/torrent/rtorrent.nix" ];

      # ...for the one that actually matches mv.tip.rtorrent's version.
      imports = [
        "${toString pinned.path}/nixos/modules/services/torrent/rtorrent.nix"
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
          package = pinned.rtorrent;
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
            # Advertise the peer port over DHT too; otherwise DHT picks a
            # random UDP port that the firewall does not open.
            dht.override_port.set = ${toString peerPort}

            # Do not pin network.bind_address: libtorrent then opens both an
            # IPv4 and an IPv6 listener. Setting it to 0.0.0.0 silently
            # disables the IPv6 listen socket.
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
            "bulk_magnet"
            "check_port"
            "cpuload"
            "datadir"
            "diskspace"
            "edit"
            "erasedata"
            "filedrop"
            "history"
            "ratio"
            "retrackers"
            "seedingtime"
            "source"
            "theme"
            "trafic"
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
      # services.rtorrent.openFirewall only opens TCP; DHT listens on UDP at
      # the same peer port. The nftables rule is family-agnostic, so this
      # covers IPv4 and IPv6.
      networking.firewall.allowedUDPPorts = [ peerPort ];
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
          # rutorrent runs commands as the rtorrent user (scheduled plugin
          # updates, external-program probes). Keep php on its PATH; the
          # module already adds procps for _task's pgrep dependency.
          path = [ config.services.phpfpm.phpPackage ];
          after = [ "media2.mount" ];
          requires = [ "media2.mount" ];
        };
        # The module's setup script chmods the share tree to 0755, which leaves
        # rtorrent unable to create the probe files used by ruTorrent's
        # external-program checks. Both users share the rutorrent group.
        # 5.3.x also ships conf/xmlrpc_proxy.php, which the 5.2.x-era module
        # does not link into place.
        #
        # Drop the previous package's plugin/php trees first: the module only
        # adds the configured plugins, so removed ones would otherwise linger
        # and keep loading.
        rutorrent-setup.script = lib.mkBefore ''
          rm -rf ${config.services.rutorrent.dataDir}/plugins/* ${config.services.rutorrent.dataDir}/php
        '';
        rutorrent-setup.serviceConfig.ExecStartPost = [
          "${pkgs.coreutils}/bin/ln -sf ${pkgs.rutorrent}/conf/xmlrpc_proxy.php ${config.services.rutorrent.dataDir}/conf/xmlrpc_proxy.php"
          "${pkgs.coreutils}/bin/chmod -R g+w ${config.services.rutorrent.dataDir}/share"
        ];
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
