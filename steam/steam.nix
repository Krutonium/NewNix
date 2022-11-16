{ config, pkgs, lib, ... }:
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
    };
  };
}
