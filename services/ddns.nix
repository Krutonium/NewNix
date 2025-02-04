{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.services;
  check-script = pkgs.writeShellScript "check-ip-change" ''
    STATE_FILE=/persist/ip_state
    AUTH_FILE=/persist/ddnsclient.auth
    CURRENT_IP=$(curl -s --config "$AUTH_FILE" https://api64.ipify.org)

    if [ -f "$STATE_FILE" ]; then
      PREVIOUS_IP=$(cat "$STATE_FILE")
      if [ "$CURRENT_IP" = "$PREVIOUS_IP" ]; then
        exit 0
      fi
    fi

    echo "$CURRENT_IP" > "$STATE_FILE"
    PASSWORD=$(cat "$AUTH_FILE")
    curl -s "https://dynamicdns.park-your-domain.com/update?domain=krutonium.ca&password=$PASSWORD&host=@"
    curl -s "https://dynamicdns.park-your-domain.com/update?domain=krutonium.ca&password=$PASSWORD&host=*"
  '';
in
{
  config = mkIf (cfg.ddns == true) {
    systemd.services.update_domain = {
      description = "Check External IP and Trigger cURL on Change";
      after = [ "network-online.target" "sys-subsystem-net-devices-WAN.device" "network.target"];
      wants = [ "network-online.target" "sys-subsystem-net-devices-WAN.device" "update_domain.path" ];
      bindsTo = [ "sys-subsystem-net-devices-WAN.device" ];
      path = [ pkgs.curl ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${check-script}";
        User = "nobody";
        Group = "nogroup";
      };
    };

    systemd.timers.update_domain = {
      description = "Timer for Domain Update";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "1min";
        OnUnitActiveSec = "5min";
        Unit = "update_domain.service";
      };
    };

    systemd.paths.update_domain = {
      description = "Trigger Domain Update when WAN IP changes";
      wantedBy = [ "multi-user.target" ];
      pathConfig = {
        PathExistsGlob = "/run/systemd/netif/leases/*";
        Unit = "update_domain";
      };
    };
  };
}
