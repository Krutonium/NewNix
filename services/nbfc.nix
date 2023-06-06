{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.services;
  myUser = "Krutonium";
  command = "bin/nbfc_service --config-file '/home/${myUser}/.config/nbfc.json'";
in
{
  config = mkIf (cfg.nbfc == true) {
    systemd.services.nbfc_service = {
      enable = true;
      description = "NoteBook FanControl service";
      serviceConfig.Type = "simple"; #related upstream config: https://github.com/nbfc-linux/nbfc-linux/blob/main/etc/systemd/system/nbfc_service.service.in
      path = [ pkgs.kmod pkgs.nbfc-linux ];
      script = "${pkgs.nbfc-linux}${command}";
      wantedBy = [ "multi-user.target" ];
    };
  };
}

