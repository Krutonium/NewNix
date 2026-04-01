{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with builtins;
let
  cfg = config.sys.services;
in
{
  config = mkIf (cfg.ut99 == true) {
    networking.firewall.allowedTCPPorts = [
      5080
    ];
    networking.firewall.allowedUDPPorts = [
      7777
      7778
    ];
    virtualisation.oci-containers = {
      backend = "docker";

      containers.ut99 = {
        image = "lacledeslan/gamesvr-ut99";

        # Equivalent to --net=host
        extraOptions = [
          "--network=host"
        ];

        volumes = [
          "/var/lib/ut99:/data"
        ];

        # Override the container command
        cmd = [
          "/app/ucc"
          "server"
          "dm-Turbine?game=Botpack.DeathMatchPlus"
          "ini=/data/UnrealTournament-Online.ini"
          "log=/data/logfile.log"
          "-nohomedir"
          "-adminconsole"
          "-http"
        ];
      };
    };
  };
}
