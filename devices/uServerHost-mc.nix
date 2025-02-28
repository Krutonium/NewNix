{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.minecraftServers;

  mkServerService = server:
    let
      serverDir = "/servers/${server.name}";
      startScript = "${serverDir}/${server.script}";  # Use the script provided per server
      rconPort = server.rconPort or 25575;  # Default to 25575 if not specified
      rconPassword = server.rconPassword or "";  # You can define this elsewhere securely
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
            pkgs.bash
          ];
          # Shutdown server via RCON on service stop
          ExecStop = "${pkgs.mcrcon}/bin/mcrcon -H 127.0.0.1 -P ${toString rconPort} -p ${rconPassword} /stop";
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
          script = mkOption {
            type = types.str;
            description = "Start script for the Minecraft server (e.g., nix-start.sh).";
            default = "nix-start.sh";  # Default script if not specified
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
            default = 25575;  # Default RCON port
          };
          rconPassword = mkOption {
            type = types.str;
            description = "The RCON password for the Minecraft server.";
            default = "";  # Leave it empty to be handled manually later
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
