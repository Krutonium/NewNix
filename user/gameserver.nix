{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.users;
in
{
  config = mkIf (cfg.gameserver == true) {
    users.users.gameserver = {
      uid = 500;
      isNormalUser = true;
      home = "/srv/games/";
      createHome = true;
      group = "gameserver";
      description = "Game Server User";
    };
  };
}
