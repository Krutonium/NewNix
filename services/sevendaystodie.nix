{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.services;
  gamePath = "/home/krutonium/7daystodie";
in
{
  config = mkIf (cfg.sevendaystodie == true) {
    networking.firewall.allowedTCPPorts = [ 26900 ];
    networking.firewall.allowedUDPPortRanges = [ { from = 26900; to = 26903; } ];
    systemd = {          
      services.7daystodie = {
        serviceConfig.Type = "oneshot";
        serviceConfig.User = "krutonium";
        path = with pkgs; [ pkgs.steam-run pkgs.steamcmd ];
        script = ''
	  mkdir -p ${gamePath}
          cd ${gamePath}
          steamcmd +force_install_dir ./ +login anonymous +app_update 294420 +quit
          steam-run ./startserver.sh -configfile=serverconfig-7dtd.xml
        '';
        enable = true;
      };
    };
  };
}
