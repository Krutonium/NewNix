{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.minecraftServers;

  mkServerService = server:
    let
      serverDir = "/servers/${server.name}";
      startScript = "${serverDir}/nix-start.sh";
    in
    if server.enabled then {
      name = "minecraft-${server.name}";
      value = {
        description = "Minecraft Server (${server.name})";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        preStart = ''
          # Ensure correct ownership and permissions
          mkdir -p ${serverDir}
          chown -R minecraft:minecraft ${serverDir}
          chmod -R 755 ${serverDir}
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
        };
      };
    } else
      null;

  serverServices = builtins.listToAttrs (filter (x: x != null) (map mkServerService cfg.servers));
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
          java = mkOption {
            type = types.package;
            description = "Java package for the server.";
          };
          enabled = mkOption {
            type = types.bool;
            default = true;
            description = "Whether to enable this server.";
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

    users.groups.minecraft = {};

    # Define the systemd services
    systemd.services = serverServices;
  };
}
