{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.services;
  updateScript = pkgs.writeShellScriptBin "update-script" ''
    systemctl stop gryphon.service
    sudo -u krutonium nupdate
    sudo -u krutonium nboot
    sudo systemctl reboot now
  '';
in
{
  config = mkIf (cfg.schedule-updates == true) {
    # Define the script
    systemd.services.schedule-update = {
      description = "Update the system on odd days from Unix Epoch";
      startAt = "*-*-* 04:00:00";
      enable = true;
      restartIfChanged = false;
      path = [ pkgs.sudo ];
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        RemainAfterExit = true;
        ExecStart = "${updateScript}/bin/update-script";
        };
      };
    };
  }
