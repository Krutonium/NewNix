{ ... }:
{
  flake.nixosModules.ut99 =
    { config, ... }:
    {
      networking.firewall.allowedTCPPorts = [ 5080 ];
      networking.firewall.allowedUDPPorts = [
        7777
        7778
      ];
      services.nginx.virtualHosts = {
        "unreal.${config.networking.domain}" = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass = "http://10.0.0.3:5080";
          };
        };
      };
      virtualisation.oci-containers = {
        backend = "docker";
        containers.ut99 = {
          image = "lacledeslan/gamesvr-ut99";
          extraOptions = [ "--network=host" ];
          volumes = [
            "/var/lib/ut99/config:/data"
            "/var/lib/ut99/mods:/app"
          ];
          cmd = [
            "/app/ucc"
            "server"
            "dm-Turbine?game=Botpack.DeathMatchPlus"
            "ini=/data/UnrealTournament-Online.ini"
            "log=/data/logfile.log"
            "-nohomedir"
            "-adminconsole"
            "-http"
            "-autobots=true"
            "-maxbots=6"
            "-botskill=2"
          ];
        };
      };
    };
}
