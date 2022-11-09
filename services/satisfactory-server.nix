{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.services;
in
{
  config = mkIf (cfg.satisfactoryServer == true) {
    networking.firewall.allowedTCPPorts = [ 15777 15000 7777 ];
    networking.firewall.allowedUDPPorts = [ 15777 15000 7777 ];
    systemd.services.satisfactory = {
      description = "Satisfactory Dedicated Server";
      serviceConfig = {
        Type = "simple";
        User = "gameserver";
        WorkingDirectory = "/srv/games/satisfactory";
        Restart = "on-failure";
        KillSignal = "SIGINT";
      };
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      path = [ pkgs.steam-run-native pkgs.steamcmd ];
      script = ''
        steamcmd +force_install_dir /srv/games/satisfactory +login anonymous +app_update 1690800 +quit
        steam-run /srv/games/satisfactory/Server/FactoryServer.sh -NOSTEAM
      '';
      enable = cfg.satisfactory_server;
    };
  };
}