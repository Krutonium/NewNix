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
        WorkingDirectory = "/home/krutonium/RubberDragonTrain";
        User = "krutonium";
        Restart = "always";
        KillSignal = "SIGINT";
      };
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      path = [ pkgs.jre pkgs.bash pkgs.screen ];
      script =
        ''
          # ${pkgs.screen}/screen -DmS rubber 
          /home/krutonium/RubberDragonTrain/run.sh
        '';
    };
  };
}
