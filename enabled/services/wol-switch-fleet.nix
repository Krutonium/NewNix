{ self, ... }:
{
  # Import on uWebServer. Wakes the target at midnight, runs switch-fleet,
  # and powers it back off afterwards only if we had to send WOL.
  flake.nixosModules.wol-switch-fleet =
    { config, lib, pkgs, ... }:
    let
      cfg = config.services.wolSwitchFleet;

      script = pkgs.writeShellApplication {
        name = "wol-switch-fleet";
        runtimeInputs = with pkgs; [ wakeonlan openssh coreutils bash ];
        text = ''
          HOST=${lib.escapeShellArg cfg.host}
          MAC=${lib.escapeShellArg cfg.mac}
          BROADCAST=${lib.escapeShellArg cfg.broadcast}
          SSH_USER=${lib.escapeShellArg cfg.user}
          KEY=${lib.escapeShellArg (toString cfg.identityFile)}

          is_up() {
            timeout 3 bash -c "exec 3<>/dev/tcp/$HOST/22" 2>/dev/null
          }

          rssh() {
            ssh -i "$KEY" \
              -o BatchMode=yes \
              -o ConnectTimeout=10 \
              -o StrictHostKeyChecking=accept-new \
              "$SSH_USER@$HOST" "$@"
          }

          wait_for_ssh() {
            local deadline=$((SECONDS + $1))
            until is_up; do
              if [ "$SECONDS" -ge "$deadline" ]; then return 1; fi
              sleep 5
            done
          }

          cleanup_poweroff() {
            rssh 'sudo -n shutdown -c || true'   # clear the pending 2AM reboot
            rssh 'sudo -n systemctl poweroff' || true  # ssh drops as the host goes down
            echo "powered off $HOST"
          }

          was_on=0
          if is_up; then was_on=1; fi   # BEFORE sending WOL

          if [ "$was_on" -eq 0 ]; then
            echo "$HOST is down, sending WOL"
            wakeonlan -i "$BROADCAST" "$MAC"
            if ! wait_for_ssh ${toString cfg.bootTimeoutSeconds}; then
              echo "$HOST never came up" >&2
              exit 1
            fi
          fi

          # Only power off if we woke it. Fires even if switch-fleet fails or times out.
          trap '[ "$was_on" -eq 0 ] && cleanup_poweroff' EXIT

          # Runs as the SSH user (not root): switch-fleet cds into ~/NixOS
          rssh 'timeout ${toString cfg.switchTimeoutMinutes}m switch-fleet'
        '';
      };
    in
    {
      options.services.wolSwitchFleet = {
        enable = lib.mkEnableOption "scheduled WOL + switch-fleet run";
        host = lib.mkOption { type = lib.types.str; example = "10.0.0.2"; };
        mac = lib.mkOption { type = lib.types.str; example = "aa:bb:cc:dd:ee:ff"; };
        broadcast = lib.mkOption {
          type = lib.types.str;
          default = "10.0.0.255";
          description = "Subnet broadcast address of the target's LAN.";
        };
        user = lib.mkOption { type = lib.types.str; description = "SSH user on the target (passwordless sudo)."; };
        identityFile = lib.mkOption { type = lib.types.path; description = "Private key readable by root."; };
        schedule = lib.mkOption { type = lib.types.str; default = "*-*-* 00:00:00"; };
        bootTimeoutSeconds = lib.mkOption { type = lib.types.int; default = 300; };
        switchTimeoutMinutes = lib.mkOption {
          type = lib.types.int;
          default = 90;
          description = "Hard cap so the poweroff always happens before the 2AM reboot.";
        };
      };

      config = lib.mkIf cfg.enable {
        systemd.services.wol-switch-fleet = {
          description = "Wake ${cfg.host}, run switch-fleet, power off if it was off";
          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = lib.getExe script;
            TimeoutStartSec = "${toString (cfg.switchTimeoutMinutes + 20)}m";
          };
        };

        systemd.timers.wol-switch-fleet = {
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = cfg.schedule;
            Persistent = false;
          };
        };
      };
    };

  # Import on uGamingPC. Just enables Wake-on-LAN on the NIC.
  flake.nixosModules.wol-target =
    { config, lib, ... }:
    let
      cfg = config.services.wolTarget;
    in
    {
      options.services.wolTarget = {
        enable = lib.mkEnableOption "Wake-on-LAN on this machine";
        interface = lib.mkOption { type = lib.types.str; example = "eno1"; };
      };

      config = lib.mkIf cfg.enable {
        networking.interfaces.${cfg.interface}.wakeOnLan.enable = true;
      };
    };
}
