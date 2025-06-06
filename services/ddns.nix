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
  check-script = pkgs.writeShellScript "check-ip-change" ''
    STATE_FILE=/persist/ip_state
    AUTH_FILE=/persist/ddnsclient.auth
    CURRENT_IP=$(curl -s https://ipv4.icanhazip.com/)
    PASSWORD=$(cat "$AUTH_FILE")
    echo Updating "@"
    curl -s "https://dynamicdns.park-your-domain.com/update?domain=krutonium.ca&password=$PASSWORD&host=@"
    echo Updating "*"
    curl -s "https://dynamicdns.park-your-domain.com/update?domain=krutonium.ca&password=$PASSWORD&host=*"
    echo Updating "vanilla"
    curl -s "https://dynamicdns.park-your-domain.com/update?domain=krutonium.ca&password=$PASSWORD&host=vanilla"
    echo Updating "aof7"
    curl -s "https://dynamicdns.park-your-domain.com/update?domain=krutonium.ca&password=$PASSWORD&host=aof7"
  '';
in
{
  config = mkIf (cfg.ddns == true) {
    systemd.services.update_domain = {
      description = "Check External IP and Trigger cURL on Change";
      after = [
        "network-online.target"
        "sys-subsystem-net-devices-WAN.device"
        "network.target"
      ];
      wants = [
        "network-online.target"
        "sys-subsystem-net-devices-WAN.device"
        "update_domain.path"
      ];
      bindsTo = [ "network-online.target" ];
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
        OnUnitActiveSec = "20min";
        Unit = "update_domain.service";
      };
    };
  };
}
