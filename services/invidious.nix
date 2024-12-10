{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.services;
in
{
  config = mkIf (cfg.invidious == true) {
    services.invidious = {
      enable = true;
      domain = "video.krutonium.ca";
      nginx.enable = true;
      settings.db.user = "invidious";
    };
    services.postgresql.ensureUsers = [ { name = "invidious"; ensureDBOwnership = true; } ];
  };
}
