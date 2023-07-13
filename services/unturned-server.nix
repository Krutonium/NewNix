{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.services;
in
{
  config = mkIf (cfg.unturnedServer == true) {
    networking.firewall.allowedTCPPorts = [ 27015 27016 ];
    networking.firewall.allowedUDPPorts = [ 27015 27016 ];
    systemd.services.unturned = {
      description = "Unturned Dedicated Server";
      serviceConfig = {
        Type = "simple";
        User = "krutonium";
        WorkingDirectory = "/media2/Unturned";
        Restart = "on-failure";
        KillSignal = "SIGINT";
      };
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      path = [ pkgs.steam-run-native pkgs.steamcmd ];
      script = ''
        steamcmd +force_install_dir /media2/Unturned +login anonymous +app_update 1690800 +quit
        steam-run /srv/games/satisfactory/Server/FactoryServer.sh -NOSTEAM
      '';
      enable = cfg.unturnedServer;
    };
  };
}
