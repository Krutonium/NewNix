{ ... }:
{
  flake.nixosModules.minecraftServerData =
    { lib, ... }:
    {
      options.minecraftServerData.servers = lib.mkOption {
        type = lib.types.listOf lib.types.attrs;
        readOnly = true;
        default = [
          #{
          #  name = "AtM10_Sky";
          #  javaVersion = "jdk21";
          #  script = "run.sh";
          #  enabled = true;
          #  rconPort = 12370;
          #  port = 25570;
          #  extraTCPPorts = [];
          #  extraUDPPorts = [ 24454 ];
          #}
          {
            name = "vanilla";
            javaVersion = "jdk21";
            script = "startserver.sh";
            enabled = true;
            rconPort = 12347;
            port = 25565;
            extraTCPPorts = [ ];
            extraUDPPorts = [
              19132
              24455
            ];
          }
          {
            name = "create_chronicles";
            javaVersion = "jdk21";
            script = "run.sh";
            enabled = true;
            rconPort = 12348;
            port = 25568;
            extraTCPPorts = [ ];
            extraUDPPorts = [ ];
          }
          {
            name = "Hytale";
            javaVersion = "jdk25";
            script = "startserver.sh";
            enabled = true;
            rconPort = 0;
            port = 25565;
            extraTCPPorts = [ ];
            extraUDPPorts = [ 5520 ];
          }
          {
            name = "FTBSkies";
            javaVersion = "jdk21";
            script = "run.sh";
            enabled = true;
            port = 25570;
            rconPort = 12349;
            extraTCPPorts = [ ];
            extraUDPPorts = [ ];
          }
        ];
        description = "Minecraft server definitions, shared between minecraftServers and minecraftPortForwards.";
      };
    };
}
