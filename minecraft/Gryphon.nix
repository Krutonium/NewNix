{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.minecraft;
  port = 25565;
in
{
  config = mkIf (cfg.gryphon == true) {
    networking.firewall.allowedTCPPorts = [ port ];
    fileSystems."/media2/Gryphon" = {
      device = "/media2/Gryphon.btrfs";
      options = [ "compress=zstd:15" ];
    };
    systemd.services.gryphon = {
      description = "Gryphon Minecraft Server";
      serviceConfig = {
        Type = "simple";
        WorkingDirectory = "/media2/Gryphon/server/";
        User = "krutonium";
        Restart = "always";
        KillSignal = "SIGINT";
      };
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      path = [ pkgs.jre pkgs.bash pkgs.screen ];
      script =
        ''
          /media2/Gryphon/server/run.sh
        '';
    };
    systemd.services.snapshotter-hourly = {
      description = "Automatic Snapshots of Minecraft Server";
      serviceConfig = {
        type = "simple";
        WorkingDirectory = "/media2/Gryphon";
        User = "root";
        KillSignal = "SIGINT";
      };
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.btrfs-progs pkgs.btrfs-snap ];
      script =
        ''
          btrfs-snap -r -c /media2/Gryphon/ hourly 72
        '';
    };
    systemd.timers.snapshotter-hourly = {
      wantedBy = [ "timers.target" ];
      partOf = [ "snapshotter.service" ];
      timerConfig.OnCalendar = [ "hourly" ];
    };
  };
}
