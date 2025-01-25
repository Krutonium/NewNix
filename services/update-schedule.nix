{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.services;
in
{
  config = mkIf (cfg.schedule-updates == true) {
      # Define the script
      systemd.services.odd-day-task = {
        description = "Update the system on odd days from Unix Epoch";
        serviceConfig = {
          Type = "oneshot";
          User = "root";
          ExecStart = ''
            #!/usr/bin/env bash
    
            # Calculate the number of days since the Unix epoch
            days_since_epoch=$(( $(date +%s) / 86400 ))
    
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
    
      # This will result in the updates happening at 4 AM every other day.
      systemd.timers.odd-day-task = {
        description = "Timer for odd-day-task service";
        wants = [ "odd-day-task.service" ];
        timerConfig = {
          OnCalendar = "*-*-* 04:00:00";
          Persistent = true;
        };
      };
    
      # Ensure the timer is started and enabled
      systemd.services."odd-day-task".wantedBy = [ "timers.target" ];
  }
}