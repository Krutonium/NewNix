{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.services;
in
{
  config = mkIf (cfg.schedule-updates == true) {
      # Define the script
      systemd.services.schedule-update = {
        description = "Update the system on odd days from Unix Epoch";
        startAt = "*-*-* 04:00:00";
        enable = false;
        restartIfChanged = false;
        path = [ pkgs.sudo ];
        serviceConfig = {
          Type = "oneshot";
          User = "root";
          RemainAfterExit = true;
          ExecStart = ''
            days_since_epoch=$(( $(date +%s) / 86400 )) # Calculate the number of days since the Unix epoch
    
            # Check if the number of days is odd
            if (( days_since_epoch % 2 == 1 )); then
              # Update the Lock File, Stop `gryphon.service` and then update and reboot.
              systemctl stop gryphon.service
              sudo -u krutonium nupdate
              sudo -u krutonium nboot
              sudo systemctl reboot now
            else
              echo "Not an odd-numbered day, skipping."
            fi
          '';
        };
      };
  };
}