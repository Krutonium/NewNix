{ ... }:
{
  flake.nixosModules.minecraftServers =
    { config, lib, pkgs, ... }:
    with lib;
    let
      cfg = config.minecraftServers;

      mkServerService =
        server:
        let
          serverDir = "/servers/${server.name}";
          startScript = "${serverDir}/${server.script}";
          host = "127.0.0.1";
        in
        if server.enabled then
          {
            name = "minecraft-${server.name}";
            value = {
              script = ''
                java --version
                ${startScript}
              '';
              preStop = ''
                password=`${pkgs.coreutils}/bin/cat ${server.rconPasswordFile}`
                ${pkgs.mcrcon}/bin/mcrcon -H ${host} -P ${toString server.rconPort} -p "$password" -w 1 "say Shutting Down!" "say 5" "say 4" "say 3" "say 2" "say 1" stop
              '';
              path = [ pkgs.bash pkgs.coreutils server.java ];
              serviceConfig = {
                WorkingDirectory = serverDir;
                Restart = "always";
                TimeoutStopSec = "120s";
                User = "minecraft";
                Group = "minecraft";
                Environment = [
                  "JAVA_HOME=${server.java.home}"
                  "PATH=${server.java}/bin:$PATH"
                ];
              };
              wantedBy = [ "multi-user.target" ];
              after = [
                "sys-subsystem-net-devices-WAN.device"
                "systemd-networkd-wait-online.service"
              ];
              requires = [ "wait-for-internet.service" ];
              wants = [ "systemd-networkd-wait-online.service" ];
              bindsTo = [ "sys-subsystem-net-devices-WAN.device" ];
              description = "Minecraft Server (${server.name})";
            };
          }
        else
          null;

      mkBackupService =
        server:
        let
          serverDir = "/servers/${server.name}";
          host = "127.0.0.1";
        in
        if server.enabled then
          {
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
                btrfs-snap -r -c -B /servers/snapshots/${server.name}/ . hourly 720
              '';
            };
          }
        else
          null;

      mkDailyBackupService =
        server:
        let
          serverDir = "/servers/${server.name}";
          backupDir = "/backups/${server.name}";
          host = "127.0.0.1";
        in
        if server.enabled then
          {
            name = "backup-daily-${server.name}";
            value = {
              description = "Daily Backup Service for Minecraft Server (${server.name})";
              after = [ "network.target" ];
              path = [ pkgs.p7zip pkgs.mcrcon pkgs.coreutils ];
              startAt = "*-*-* 07:00:00";
              serviceConfig = {
                Type = "oneshot";
                WorkingDirectory = serverDir;
                User = "root";
                Group = "root";
              };
              script = ''
                mkdir -p ${backupDir}
                password=`${pkgs.coreutils}/bin/cat ${server.rconPasswordFile}`
                ${pkgs.mcrcon}/bin/mcrcon -H ${host} -P ${toString server.rconPort} -p "$password" -w 60 "say Daily Reboot in 2 minutes" "say Daily Reboot in 1 Minute" "say Rebooting Now (for Backup)"
                ${pkgs.mcrcon}/bin/mcrcon -H ${host} -P ${toString server.rconPort} -p "$password" -w 1 save-all
                systemctl stop minecraft-${server.name}
                DATE=$(date +%Y-%m-%d)
                nice -n 19 ${pkgs.p7zip}/bin/7z a "${backupDir}/$DATE.7z" ./*
                find ${backupDir} -name "*.7z" -type f -mtime +30 -delete
                systemctl start minecraft-${server.name}
              '';
            };
          }
        else
          null;

      serverServices = builtins.listToAttrs (filter (x: x != null) (map mkServerService cfg.servers));
      backupServices = builtins.listToAttrs (filter (x: x != null) (map mkBackupService cfg.servers));
      dailyBackupServices = builtins.listToAttrs (filter (x: x != null) (map mkDailyBackupService cfg.servers));

      enabledServers = filter (s: s.enabled) cfg.servers;
      tcpPorts = concatMap (s: [ s.port ] ++ s.extraTCPPorts) enabledServers;
      udpPorts = concatMap (s: [ s.port ] ++ s.extraUDPPorts) enabledServers;
    in
    {
      options.minecraftServers.servers = mkOption {
        type = with types; listOf (submodule {
          options = {
            name = mkOption {
              type = types.str;
              description = "Minecraft server name.";
            };
            script = mkOption {
              type = types.str;
              description = "Start script for the Minecraft server.";
              default = "start-server.sh";
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
            port = mkOption {
              type = types.int;
              default = 25565;
              description = "Primary port opened for both TCP and UDP.";
            };
            extraTCPPorts = mkOption {
              type = with types; listOf int;
              default = [];
              description = "Additional TCP ports to open for this server.";
            };
            extraUDPPorts = mkOption {
              type = with types; listOf int;
              default = [];
              description = "Additional UDP ports to open for this server.";
            };
            rconPort = mkOption {
              type = types.int;
              default = 25575;
              description = "The RCON port for the Minecraft server.";
            };
            rconPasswordFile = mkOption {
              type = types.str;
              default = "";
              description = "Path to file containing the RCON password.";
            };
          };
        });
        default = [ ];
        description = "List of Minecraft servers to manage.";
      };

      config = {
        users.users.minecraft = {
          isSystemUser = true;
          group = "minecraft";
          home = "/servers";
        };
        users.groups.minecraft.members = [ "krutonium" ];
        systemd.services = serverServices // backupServices // dailyBackupServices;
        networking.firewall.allowedTCPPorts = tcpPorts;
        networking.firewall.allowedUDPPorts = udpPorts;
      };
    };
}