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
      backupScript = "${serverDir}/backup.sh"; # Define the backup script path
    in
    if server.enabled then {
      name = "minecraft-${server.name}";
      value = {
        description = "Minecraft Server (${server.name})";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        preStart = ''
          # Custom pre-start logic (if any)
        '';
        serviceConfig = {
          WorkingDirectory = serverDir;
          ExecStart = "${pkgs.bash}/bin/bash ${startScript}";
          Restart = "always";
          User = "minecraft";
          Group = "minecraft";
          Environment = [
            "JAVA_HOME=${server.java.home}"
            "PATH=${server.java}/bin:$PATH"
          ];
          Path = [
            pkgs.bash
            pkgs.coreutils-full
            pkgs.mcrcon
          ];
          # Shutdown server via RCON on service stop
          preStop = ''
            password=`${pkgs.coreutils-full}/bin/cat ${rconPassword}`
            ${pkgs.mcrcon}/bin/mcrcon -H 127.0.0.1 -P ${toString rconPort} -p "$password" /stop
          '';
        };
      };
    } else
      null;

  mkBackupService = server:
    let
      serverDir = "/servers/${server.name}";
      backupScript = "${serverDir}/backup.sh"; # Define the backup script path
    in
    if server.enabled then {
      name = "backup-${server.name}";
      value = {
        description = "Backup Service for Minecraft Server (${server.name})";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          WorkingDirectory = serverDir;
          ExecStart = "${pkgs.bash}/bin/bash ${backupScript}";
          User = "minecraft";
          Group = "minecraft";
        };
      };
    } else
      null;

  mkBackupTimer = server:
    if server.enabled then {
      name = "backup-${server.name}.timer";
      value = {
        description = "Timer for Backup Service for Minecraft Server (${server.name})";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "*:0/15";
          Persistent = true;
        };
      };
    } else
      null;

  serverServices = builtins.listToAttrs (filter (x: x != null) (map mkServerService cfg.servers));
  backupServices = builtins.listToAttrs (filter (x: x != null) (map mkBackupService cfg.servers));
  backupTimers = builtins.listToAttrs (filter (x: x != null) (map mkBackupTimer cfg.servers));

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
    systemd.services = serverServices // backupServices;
    systemd.timers = backupTimers;
  };
}