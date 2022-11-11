{ config, pkgs-unstable, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.services;
in
{
  config = mkIf (cfg.torrent == true) {
    services.deluge = {
      package = pkgs-unstable.deluge;
      openFirewall = true;
      enable = true;
      dataDir = "/transmission";
      declarative = true;
      authFile = "/persist/deluge.auth";
      config = {
        max_upload_speed = "1000.0";
        share_ratio_limit = "120.0";
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
      };
      web = {
        enable = true;
        port = 8112;
        openFirewall = true;
      };
    };
  };
}
