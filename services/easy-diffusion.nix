{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.services;
in
{
  config = mkIf (cfg.easydiffusion == true) {
    systemd.services = {
      EasyDiffusion = {
        description = "Easy Diffusion!";
        serviceConfig = {
          type = "simple";
          WorkingDirectory = "/media2/Easy-Diffusion-Linux/easy-diffusion";
          user = "krutonium";
          Restart = "always";
        };
        wantedBy = [ "multi-user.target" ];
        path = [ pkgs.steam-run pkgs.bzip2 ];
        script = ''
          steam-run /media2/Easy-Diffusion-Linux/easy-diffusion/start.sh
        '';
        enable = true;
      };
    };
  };
}
