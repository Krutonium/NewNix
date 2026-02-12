{ config
, lib
, ...
}:
with lib;
with builtins;
let
  cfg = config.sys.desktop;
in
{
  config = mkIf (cfg.displayManager == "gdm") {
    services = {
      displayManager = {
        autoLogin = {
          user = "krutonium";
          enable = false;
        };
      };
      displayManager = {
        gdm = {
          enable = true;
          wayland = cfg.wayland;
          autoSuspend = cfg.autoSuspend;
        };
      };
    };
    systemd.services."setup-monitors" = {
      serviceConfig.Type = "oneshot";
      serviceConfig.User = "root";
      script = ''
        mkdir -p /run/gdm/.config
        cp /home/krutonium/.config/monitors.xml /run/gdm/.config/
        chown -R gdm:gdm /run/gdm/.config
      '';
      # Only enable if GDM is enabled
      enable = true;
      before = [ "display-manager.service" ];
      wantedBy = [ "display-manager.service" ];
    };
  };
}
