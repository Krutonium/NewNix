{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.minecraftServers;

  # Generate a list of enabled Minecraft services
  enabledServers = filter (server: server.enabled) cfg.servers;
  enabledServiceNames = map (server: "minecraft-${server.name}.service") enabledServers;

  mkServerService = server:
    let
      serverDir = "/servers/${server.name}";
      startScript = "${serverDir}/nix-start.sh";
    in
    if server.enabled then {
      name = "minecraft-${server.name}";
      value = {
        description = "Minecraft Server (${server.name})";
        after = [ "network.target" "minecraft-setup.service" ]; # Ensure directories are set up first
        wantedBy = [ "multi-user.target" ];
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

  serverServices = filter (x: x != null) (map mkServerService cfg.servers);

  # Define minecraft-setup service as part of serverServices
  mkSetupService = {
    name = "minecraft-setup";
    value = {
      description = "Setup Minecraft server directories and permissions";
      before = enabledServiceNames; # Ensure setup runs before all server services
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.bash}/bin/bash -c 'mkdir -p /servers && chown -R minecraft:minecraft /servers && chmod -R 755 /servers'";
        User = "root";
        Group = "root";
      };
    };
  };

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

    # Combine the setup service with the Minecraft server services
    systemd.services = lib.mkMerge [
      serverServices
      { inherit mkSetupService; }
    ];
  };
}
