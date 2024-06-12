{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.minecraft;
  ports = [ 25565 12345 ];
  location = "/media2/Gryphon";
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
    #systemd.services.rebootGryphon = {
    #  description = "Reboot Gryphon MC";
    #  path = [ pkgs.mcrcon ];
    #  script = ''
    #      password=`cat /persist/mcrcon.txt`
    #      mcrcon -H ${host} -P ${rconport} -p $password -w 5 save-all "say Daily Reboot..." stop
    #  '';
    #  serviceConfig = {
    #    Type = "oneshot";
    #    User = "root";
    #  };
    #  partOf = [ "rebootGryphon.service" ];
    #};
    #systemd.timers."rebootGryphon" = {
    #  wantedBy = [ "timers.target" ];
    #  timerConfig = {
    #    OnCalendar = "*-*-* 06:00:00";
    #    Persistant = true;
    #  };
    #};
      

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
          mcrcon -H ${host} -P ${rconport} -p $password -w 1 "say Starting Hourly Backup..." save-all save-off
          # Create 1 snapshot per hour, and keep 72 of them.
          btrfs-snap -r -c ${location} hourly 72
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
          sleep 300
          password=`cat /persist/mcrcon.txt`
          mcrcon -H ${host} -P ${rconport} -p $password -w 1 "say Starting Daily Backup..." save-all save-off
          #Create 1 snapshot per day that is kept for 15 days.
          btrfs-snap -r -c ${location} daily 15
          mcrcon -H ${host} -P ${rconport} -p $password -w 1 "say Done!" save-on
        '';
    };
    systemd.timers.snapshotter-daily = {
      wantedBy = [ "timers.target" ];
      partOf = [ "snapshotter-daily.service" ];
      timerConfig.OnCalendar = [ "daily" ];
    };
  };
}
