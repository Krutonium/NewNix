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
    systemd.services.snapshotter = {
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
          # Create 1 snapshot per hour, and keep 72 of them.
          btrfs-snap -r -c /media2/Gryphon/ hourly 72
        '';
    };
    systemd.timers.snapshotter = {
      wantedBy = [ "timers.target" ];
      partOf = [ "snapshotter.service" ];
      timerConfig.OnCalendar = [ "hourly" ];
    };


    systemd.services.snapshotter-daily = {
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
          #Create 1 snapshot per day that is kept for 15 days.
          btrfs-snap -r -c /media2/Gryphon/ daily 15
        '';
    };
    systemd.timers.snapshotter = {
      wantedBy = [ "timers.target" ];
      partOf = [ "snapshotter-daily.service" ];
      timerConfig.OnCalendar = [ "daily" ];
    };
  };
}
