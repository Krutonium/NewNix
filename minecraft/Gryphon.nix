{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.minecraft;
  port = "25565";
  location = "/media2/Gryphon";
  rconport = "25566";
  host = "127.0.0.1";
  password = builtins.readFile /persist/mcrcon.txt;
in
{
  config = mkIf (cfg.gryphon == true) {
    networking.firewall.allowedTCPPorts = [ port ];
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
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      path = [ pkgs.jre pkgs.bash ];
      script =
        ''
          /media2/Gryphon/server/run.sh
        '';
    };
    systemd.services.snapshotter = {
      description = "Automatic Snapshots of Minecraft Server";
      serviceConfig = {
        type = "simple";
        WorkingDirectory = location;
        User = "root";
        KillSignal = "SIGINT";
      };
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.btrfs-progs pkgs.btrfs-snap pkgs.mcrcon ];
      script =
        ''
          mcrcon -H ${host} -P ${port} -p ${password} say "Starting Daily Backup..."
          mcrcon -H ${host} -P ${port} -p ${password} save-all
          # Create 1 snapshot per hour, and keep 72 of them.
          btrfs-snap -r -c ${location} hourly 72
          mcrcon -H ${host} -P ${port} -p ${password} say "Done!"
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
        WorkingDirectory = location;
        User = "root";
        KillSignal = "SIGINT";
      };
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.btrfs-progs pkgs.btrfs-snap pkgs.mcrcon ];
      script =
        ''
          mcrcon -H ${host} -P ${port} -p ${password} say "Starting Daily Backup..."
          mcrcon -H ${host} -P ${port} -p ${password} save-all
          #Create 1 snapshot per day that is kept for 15 days.
          btrfs-snap -r -c ${location} daily 15
          mcrcon -H ${host} -P ${port} -p ${password} say "Done!"
        '';
    };
    systemd.timers.snapshotter-daily = {
      wantedBy = [ "timers.target" ];
      partOf = [ "snapshotter-daily.service" ];
      timerConfig.OnCalendar = [ "daily" ];
    };
  };
}
