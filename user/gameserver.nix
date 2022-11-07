{ config, ... }:
{
  users.users.gameserver = {
    isNormalUser = true;
    home = "/srv/games/";
    createHome = true;
    group = "gameserver";
    description = "Game Server User";
  };
}