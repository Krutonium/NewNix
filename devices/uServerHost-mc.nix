{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.minecraftServers;

  mkServerService = server:
    let
      serverDir = "/servers/${server.name}";
      startScript = "${serverDir}/nix-start.sh";
    in
    {
      name = "minecraft-${server.name}";
      value = {
        description = "Minecraft Server (${server.name})";
        after = [ "network.target" ];
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
    };

  serverServices = builtins.listToAttrs (map mkServerService cfg.servers);
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
        };
      });
      default = [ ];
      description = "List of Minecraft servers to manage.";
    };
  };

  config = {
    systemd.services = serverServices;
  };
}
