{ config, ... }:
{
  users.users.gameserver = {
    uid = 500;
    isNormalUser = true;
    home = "/srv/games/";
    createHome = true;
    group = "gameserver";
    description = "Game Server User";
  };
}
