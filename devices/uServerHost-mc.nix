{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.minecraftServers;

  mkServerService = server:
    let
      serverDir = "/servers/${server.name}";
      startScript = "${serverDir}/${server.script}"; # Use the script provided per server
      rconPort = server.rconPort or 25575; # Default to 25575 if not specified
      rconPassword = server.rconPassword or ""; # You can define this elsewhere securely
      host = "127.0.0.1";
    in
    if server.enabled then {
      name = "minecraft-${server.name}";
      value = {
        script = ''
          java --version
          ${startScript}
        '';
        preStop = ''
          # Use mcron to send a shutdown message to the server
            password=`${pkgs.coreutils}/bin/cat ${server.rconPasswordFile}`
            ${pkgs.mcrcon}/bin/mcrcon -H ${host} -P ${toString server.rconPort} -p "$password" -w 1 "say Shutting Down!" "say 5" "say 4" "say 3" "say 2" "say 1" stop
        '';
        path = [ pkgs.bash server.java ];
        serviceConfig = {
          WorkingDirectory = serverDir;
          Restart = "always";
          User = "minecraft";
          Group = "minecraft";
          Environment = [
            "JAVA_HOME=${server.java.home}"
            "PATH=${server.java}/bin:$PATH"
          ];
        };
        wantedBy = [ "multi-user.target" ];
        after = [ "sys-subsystem-net-devices-WAN.device" ];
        bindsTo = [ "sys-subsystem-net-devices-WAN.device" ];
        description = "Minecraft Server (${server.name})";
      };
    } else
      null;

  mkBackupService = server:
    let
      serverDir = "/servers/${server.name}";
      host = "127.0.0.1"; # Localhost for now
    in
    if server.enabled then {
      name = "backup-${server.name}";
      value = {
        description = "Backup Service for Minecraft Server (${server.name})";
        after = [ "network.target" "minecraft-${server.name}.service" ];
        wantedBy = [ "multi-user.target" ];
        path = [ pkgs.btrfs-progs pkgs.btrfs-snap pkgs.mcrcon pkgs.coreutils ];
        startAt = "*:0/15";
        serviceConfig = {
          Type = "oneshot";
          WorkingDirectory = serverDir;
          User = "root";
          Group = "root";
        };
        script = ''
          # Sleeping 5 minutes in case the server isn't up yet.
          #sleep 5m
          #password=`${pkgs.coreutils}/bin/cat ${server.rconPasswordFile}`
          #${pkgs.mcrcon}/bin/mcrcon -H ${host} -P ${toString server.rconPort} -p "$password" -w 1 "say Starting Backup..." save-off save-all
          # Create snapshot
          btrfs-snap -r -c -B /servers/snapshots/${server.name}/ . hourly 192
          #${pkgs.mcrcon}/bin/mcrcon -H ${host} -P ${toString server.rconPort} -p "$password" -w 1 save-on "say Done!"
        '';
      };
    } else
      null;

  mkDailyBackupService = server:
    let
      serverDir = "/servers/${server.name}";
      backupDir = "/backups/${server.name}";
      rconPort = server.rconPort or 25575; # Default to 25575 if not specified
      host = "127.0.0.1";
    in
    if server.enabled then {
      name = "backup-daily-${server.name}";
      value = {
        description = "Daily Backup Service for Minecraft Server (${server.name})";
        after = [ "network.target" ];
        path = [ pkgs.p7zip pkgs.mcrcon pkgs.coreutils ];
        startAt = "*-*-* 02:00:00";
        serviceConfig = {
          Type = "oneshot";
          WorkingDirectory = serverDir;
          User = "minecraft";
          Group = "minecraft";
        };
        script = ''
          # Create a backup directory - In case it doesn't exist
          mkdir -p ${backupDir}
          # Warn the players that a backup is starting
          password=`${pkgs.coreutils}/bin/cat ${server.rconPasswordFile}`
          ${pkgs.mcrcon}/bin/mcrcon -H ${host} -P ${toString server.rconPort} -p "$password" -w 1 "say Starting Big Fat Daily Backup..." save-off save-all
          DATE=$(date +%Y-%m-%d)
          nice -n 19 ${pkgs.p7zip}/bin/7z a -mx9 -mmf=bt2 "${backupDir}/$DATE.7z" ./*
          # Let the players know the backup is done
          ${pkgs.mcrcon}/bin/mcrcon -H ${host} -P ${toString server.rconPort} -p "$password" -w 1 save-on "say Daily Backup Complete!"
          find ${backupDir} -name "*.7z" -type f -mtime +7 -delete
        '';
      };
    } else
      null;
  dailyBackupServices = builtins.listToAttrs (filter (x: x != null) (map mkDailyBackupService cfg.servers));
  serverServices = builtins.listToAttrs (filter (x: x != null) (map mkServerService cfg.servers));
  backupServices = builtins.listToAttrs (filter (x: x != null) (map mkBackupService cfg.servers));
in
{
  options.minecraftServers = {
    servers = mkOption {
      type = with types; listOf (submodule {
        options = {
          name = mkOption {
            type = types.str;
            description = "Minecraft server name.";
          };
          script = mkOption {
            type = types.str;
            description = "Start script for the Minecraft server (e.g., start-server.sh).";
            default = "start-server.sh"; # Default script if not specified
          };
          java = mkOption {
            type = types.package;
            description = "Java package for the server.";
          };
          enabled = mkOption {
            type = types.bool;
            default = true;
            description = "Whether to enable this server.";
          };
          rconPort = mkOption {
            type = types.int;
            description = "The RCON port for the Minecraft server.";
            default = 25575; # Default RCON port
          };
          rconPasswordFile = mkOption {
            type = types.str;
            description = "The RCON password for the Minecraft server.";
            default = ""; # Leave it empty to be handled manually later
          };
        };
      });
      default = [ ];
      description = "List of Minecraft servers to manage.";
    };
  };

  config = {
    # Ensure the `minecraft` user and group exist
    users.users.minecraft = {
      isSystemUser = true;
      group = "minecraft";
      home = "/servers"; # Optional, but good practice
    };

    users.groups.minecraft = { };

    # Define the systemd services and timers
    systemd.services = serverServices // backupServices // dailyBackupServices;
  };
}
