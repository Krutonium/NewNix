{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.minecraft;
  port = "25565";
in
{
  config = mkIf (cfg.stoneblock3 == true) {
    networking.firewall.allowedTCPPorts = [ port ];
    systemd.services.stoneblock3 = {
      description = "Stoneblock 3 Minecraft Server";
      serviceConfig = {
        Type = "simple";
        WorkingDirectory = "/srv/games/StoneBlock3";
        User = "gameserver";
        Restart = "always";
        KillSignal = "SIGINT";
      };
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      path = [ pkgs.openjdk17 pkgs.steam-run-native pkgs.screen ];
      script =
        ''
          screen -DmS stoneblock3 ${pkgs.steam-run-native}/steam-run ${pkgs.openjdk17}/java -Xms${toString cfg.stoneblock3Memory}M -Xmx${toString cfg.stoneblock3Memory}M -jar /srv/games/StoneBlock3/forge-1.12.2-14.23.5.2855-universal.jar nogui
        '';
    };
  };
}