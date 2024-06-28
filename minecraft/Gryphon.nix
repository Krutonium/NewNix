{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.minecraft;
  ports = [ 25565 12345 ];
  location = "/persist/gryphon";
  rconport = "12345";
  host = "127.0.0.1";
in
{
  config = mkIf (cfg.gryphon == true) {
    networking.firewall.allowedTCPPorts = ports;
    #fileSystems."${location}" = {
    #  device = "/media2/Gryphon.btrfs";
    #  options = [ "compress=zstd:15" ];
    #};
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

    systemd.services.snapshotter = {
      description = "Automatic Snapshots of Minecraft Server";
      serviceConfig = {
        type = "simple";
        WorkingDirectory = location;
        User = "root";
        KillSignal = "SIGINT";
      };
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.btrfs-progs pkgs.btrfs-snap pkgs.mcrcon pkgs.coreutils ];
      script =
        ''
          sleep 300
          password=`cat /persist/mcrcon.txt`
          mcrcon -H ${host} -P ${rconport} -p $password -w 1 "say Starting Hourly Backup..." save-off save-all
          # Create 1 snapshot per hour, and keep 24 of them.
          btrfs-snap -r -c ${location} hourly 24
          mcrcon -H ${host} -P ${rconport} -p $password -w 1 save-on "say Done!"
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
      path = [ pkgs.btrfs-progs pkgs.btrfs-snap pkgs.mcrcon pkgs.coreutils ];
      script =
        ''
          sleep 600
          password=`cat /persist/mcrcon.txt`
          mcrcon -H ${host} -P ${rconport} -p $password -w 1 "say Starting Daily Backup..." save-off save-all
          #Create 1 snapshot per day that is kept for 7 days.
          btrfs-snap -r -c ${location} daily 7
          mcrcon -H ${host} -P ${rconport} -p $password -w 1 "say Done!" save-on
          systemctl start snapshotter-send
        '';
    };
    systemd.timers.snapshotter-daily = {
      wantedBy = [ "timers.target" ];
      partOf = [ "snapshotter-daily.service" ];
      timerConfig.OnCalendar = [ "daily" ];
    };

    # Once per day, btrfs send ~/.snapshot to /media2/Gryphon/snapshots
    systemd.services.snapshotter-send = {
      description = "Send snapshots to backup server";
      serviceConfig = {
        type = "simple";
        WorkingDirectory = location;
        User = "root";
        KillSignal = "SIGINT";
      };
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.mcrcon pkgs.coreutils pkgs.p7zip ];
      script = ''
        cd ${location}/server/
        _date = $(date +%Y-%m-%d)
        7z a /media2/Gryphon/snapshots/$(date).7z .
        # Check how many backups there are
        backups=$(ls /media2/Gryphon/snapshots | wc -l)
        # If there are more than 7 backups, delete the oldest one
        if [ $backups -gt 7 ]; then
          oldest=$(ls -t /media2/Gryphon/snapshots | tail -1)
          rm /media2/Gryphon/snapshots/$oldest
        fi
      '';
    };
  };
}
