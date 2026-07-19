{ ... }:
{
  flake.nixosModules.minecraftServers =
    { config, lib, pkgs, ... }:
    with lib;
    let
      servers = config.minecraftServerData.servers;

      # Map javaVersion string -> actual package
      javaPackage = ver: pkgs.${ver} or (throw "Unknown javaVersion '${ver}' in minecraftServerData.nix");

      enabledServers = filter (s: s.enabled) servers;

      mkServerService = server:
        let
          serverDir = "/servers/${server.name}";
          startScript = "${serverDir}/${server.script}";
          host = "127.0.0.1";
          java = javaPackage server.javaVersion;
        in
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
            path = [ pkgs.bash pkgs.coreutils java ];
            serviceConfig = {
              WorkingDirectory = serverDir;
              Restart = "always";
              TimeoutStopSec = "120s";
              User = "minecraft";
              Group = "minecraft";
              Environment = [
                "JAVA_HOME=${java.home}"
                "PATH=${java}/bin:$PATH"
              ];
            };
            wantedBy = [ "multi-user.target" ];
            after = [ "network-online.target" ];
            wants = [ "network-online.target" ];
            description = "Minecraft Server (${server.name})";
          };
        };

      mkBackupService = server:
        let
          serverDir = "/servers/${server.name}";
          host = "127.0.0.1";
        in
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
        };

      mkDailyBackupService = server:
        let
          serverDir = "/servers/${server.name}";
          backupDir = "/backups/${server.name}";
          host = "127.0.0.1";
        in
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
        };

      tcpPorts = concatMap (s: [ s.port ] ++ s.extraTCPPorts) enabledServers;
      udpPorts = concatMap (s: [ s.port ] ++ s.extraUDPPorts) enabledServers;
    in
    {
      users.users.minecraft = {
        isSystemUser = true;
        group = "minecraft";
        home = "/servers";
      };
      users.groups.minecraft.members = [ "krutonium" ];

      systemd.services =
        builtins.listToAttrs (map mkServerService enabledServers)
        // builtins.listToAttrs (map mkBackupService enabledServers)
        // builtins.listToAttrs (map mkDailyBackupService enabledServers);

      networking.firewall.allowedTCPPorts = tcpPorts;
      networking.firewall.allowedUDPPorts = udpPorts;
    };
}
