{
  config,
  lib,
  pkgs,
  ...
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
    systemd.services.sync-monitors-to-gdm = {
      description = "Copy Krutonium's GNOME monitor layout to GDM";
      wantedBy = [ "gdm.service" ];
      before = [ "gdm.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "sync-monitors-to-gdm" ''
          SRC=/home/krutonium/.config/monitors.xml
          DEST=/etc/xdg/monitors.xml

          if [ ! -f "$SRC" ]; then
            echo "No monitors.xml found for krutonium, skipping."
            exit 0
          fi

          mkdir -p /etc/xdg
          install -m 644 "$SRC" "$DEST"
          echo "Copied monitors.xml to $DEST"

        '';
      };
    };
  };
}
