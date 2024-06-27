{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.minecraft;
  ports = [ 25565 12345 ];
  location = "/persist/Gryphon";
  rconport = "12345";
  host = "127.0.0.1";
in
{
  config = mkIf (cfg.gryphon == true) {
    networking.firewall.allowedTCPPorts = ports;
    fileSystems."${location}" = {
      device = "/media2/Gryphon.btrfs";
      options = [ "compress=zstd:15" ];
    };
    systemd.services.gryphon = {
      description = "Gryphon Minecraft Server";
      serviceConfig = {
        Type = "simple";
        WorkingDirectory = "${location}/server/";
        User = "krutonium";
        Restart = "always";
        KillSignal = "SIGINT";
      };
      preStop =
        ''
          password=`cat /persist/mcrcon.txt`
          ${pkgs.mcrcon}/bin/mcrcon -H ${host} -P ${rconport} -p $password -w 5 "say Shutting Down Now!" stop
        '';
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      path = [ pkgs.jre pkgs.bash ];
      script =
        ''
          /media2/Gryphon/server/run.sh
        '';
    };
    services.btrbk = {
      instances."hourly-mc" = {
        onCalendar = "hourly";
        settings = {
          volume."/persist/" = {
            target = "/media2/Gryphon/shapshots";
            subvolume = "Gryphon";
          };
        };
      };
    };
  };
}
