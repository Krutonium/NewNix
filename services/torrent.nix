{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.services;
in
{
  config = mkIf (cfg.torrent == true) {
    services.deluge = {
      enable = true;
      dataDir = "/transmission";
      declarative = true;
      authFile = "/persist/deluge.auth";
      config = {
        max_upload_speed = "1000.0";
        share_ratio_limit = "120.0";
        dont_count_slow_torrents = true;
        pre_allocate_storage = true;
      };
      web = {
        enable = true;
        port = 8112;
      };
    };
  };
}
