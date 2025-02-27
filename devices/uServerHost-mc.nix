{ config, lib, pkgs, McServers, ... }:

let
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

  serverServices = builtins.listToAttrs (map mkServerService McServers);
in
{
  systemd.services = serverServices;
}