{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.services;
in
{
  config = mkIf (cfg.torrent == true) {
    networking.firewall.allowedTCPPortRanges = [{ from = 50023; to = 50050; }];
    networking.firewall.allowedUDPPortRanges = [{ from = 50023; to = 50050; }];
    networking.firewall.interfaces."bridge".allowedTCPPorts = [ 8112 58846 ];
    services.deluge = {
      package = pkgs.deluge;
      openFirewall = true;
      enable = true;
      dataDir = "/media2/transmission";
      declarative = true;
      authFile = "/persist/deluge.auth";
      config = {
        max_upload_speed = "50000.0";
        max_half_open_connections = "500";
        max_connections_per_second = "100";
        share_ratio_limit = "5000";
        dont_count_slow_torrents = true;
        pre_allocate_storage = true;
        listen_ports = [ 50023 50023 ];
        random_port = false;
        listen_random_port = "None";
        dht = false;
        natpmp = false;
        utpex = false;
        lsd = false;
        max_connections_global = 5000;
        max_upload_slots_global = -1;
        allow_remote = true;
        max_active_seeding = "500";
        max_active_downloading = "500";
        max_active_limit = "1000";
        listen_interface = "WAN";
        outgoing_interface = "WAN";
        outgoing_ports = [ 50024 50050 ];
        random_outgoing_ports = false;
        cache_size = "8192";
        cache_expiry = "128";
      };
      web = {
        enable = true;
        port = 8112;
        openFirewall = false;
      };
    };
  };
}
