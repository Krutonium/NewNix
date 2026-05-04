{ ... }:
{
  flake.nixosModules.gnome =
    { pkgs, ... }:
    {
      config = {
        services = {
          desktopManager.gnome.enable = true;
          displayManager.gdm = {
            enable = true;
            wayland = true;
            autoSuspend = true;
          };
          gnome = {
            core-developer-tools.enable = false;
            games.enable = false;
          };
        };
        xdg.portal = {
          enable = true;
        };
        hardware.graphics = {
          enable = true;
          enable32Bit = true;
        };
        security.rtkit.enable = true;
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
        environment.gnome.excludePackages = [
          pkgs.gnome-software
          pkgs.gnome-contacts
          pkgs.gnome-tour
          pkgs.gnome-user-docs
        ];
      };
      options.sys.desktop.desktop = true;
    };
}
