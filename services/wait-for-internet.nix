{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.wait-for-internet;

  script = pkgs.writeShellScript "wait-for-internet.sh" ''
    set -eu

    ping_target="${cfg.pingTarget}"
    http_target="${cfg.httpTarget}"

    echo "Waiting for Internet: ping=$ping_target http=$http_target"

    while true; do
      # Check ping reachability
      if ${pkgs.iputils}/bin/ping -c1 -W1 "$ping_target" > /dev/null 2>&1; then
        # Check HTTP reachability
        if ${pkgs.curl}/bin/curl -s --head "$http_target" | grep "200" > /dev/null; then
          echo "Internet connection confirmed."
          exit 0
        fi
      fi

      echo "Internet not ready, retrying..."
      sleep 2
    done
  '';
in
{
  options.services.wait-for-internet = {
    enable = lib.mkEnableOption "Wait for confirmed Internet before starting dependent services";

    pingTarget = lib.mkOption {
      type = lib.types.str;
      default = "8.8.8.8";
      description = "Host to ping for connectivity check.";
    };

    httpTarget = lib.mkOption {
      type = lib.types.str;
      default = "https://example.com";
      description = "HTTP URL to check for valid response.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.wait-for-internet = {
      description = "Wait for confirmed Internet connection";

      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];

      # One-shot service: exits only when Internet confirmed
      serviceConfig = {
        Type = "oneshot";
        ExecStart = script;
        TimeoutStartSec = "5min";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };
}
