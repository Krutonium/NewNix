{ config, pkgs, lib, pkgs-master, ... }:
with lib;
with builtins;
let
  cfg = config.sys.steam;
in
{
  config = mkIf (cfg.steam == true) {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      package = pkgs-master.steam;
    };
  };
}
