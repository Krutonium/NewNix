{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.minecraft;
  port = 25565;
in
{
  config = mkIf (cfg.rubberdragontrain == true) {
    networking.firewall.allowedTCPPorts = [ port ];
    systemd.services.rubber = {
      description = "RubberDragonTrains Minecraft Server";
      serviceConfig = {
        Type = "simple";
        WorkingDirectory = "/srv/games/RubberDragonTrain";
        User = "gameserver";
        Restart = "always";
        KillSignal = "SIGINT";
      };
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      path = [ pkgs.jre pkgs.bash pkgs.screen ];
      script =
        ''
          #screen -DmS rubber 
          ${pkgs.bash}/bash /srv/games/RubberDragonTrain/run.sh
        '';
    };
  };
}
