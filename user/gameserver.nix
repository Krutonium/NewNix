{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.roles;
in
{
  config = mkIf (cfg.server == true) {
    users.users.gameserver = {
      uid = 500;
      isSystemUser = true;
      home = "/srv/games/";
      createHome = true;
      group = "gameserver";
      description = "Game Server User";
    };
    users.groups.gameserver = {};
  };
}
