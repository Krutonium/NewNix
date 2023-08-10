{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.services;
in
{
  config = mkIf (cfg.torrent == true) {
    networking.firewall.allowedTCPPorts = [ 50023 50050 ];
    networking.firewall.allowedUDPPorts = [ 50023 50050 ];
    networking.firewall.interfaces."bridge".allowedTCPPorts = [ 8112 58846 ];
    services.deluge = {
      package = pkgs.deluge;
      openFirewall = true;
      enable = true;
      dataDir = "/media2/transmission";
      declarative = true;
      authFile = "/persist/deluge.auth";
      config = {
        max_upload_speed = "1000.0";
        share_ratio_limit = "500";
        dont_count_slow_torrents = true;
        pre_allocate_storage = true;
        listen_ports = [ 50023 50023 ];
        random_port = false;
        listen_random_port = "None";
        dht = false;
        natpmp = false;
        utpex = false;
        lsd = false;
        max_connections_global = 600;
        max_upload_slots_global = -1;
        allow_remote = true;
        max_active_seeding = "500";
        max_active_downloading = "500";
        max_active_limit = "500";
        listen_interface = "enp4s0";
        outgoing_interface = "enp4s0";
        outgoing_ports = [50024 50050];
        random_outgoing_ports = false;
      };
      web = {
        enable = true;
        port = 8112;
        openFirewall = false;
      };
    };
  };
}
