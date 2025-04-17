{
  config,
  pkgs,
  lib,
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
      xserver = {
        enable = true;
        excludePackages = [ ];
        displayManager = {
          gdm = {
            enable = true;
            wayland = cfg.wayland;
            autoSuspend = cfg.autoSuspend;
          };
        };
      };
    };
    systemd.services."setup-monitors" = {
      serviceConfig.Type = "oneshot";
      serviceConfig.User = "root";
      script = ''
        SOURCE_FILE="/home/krutonium/.config/monitors.xml"

        # Destination directory
        DEST_DIR="/run/gdm/.config"

        # Check if the source file exists
        if [ -f "$SOURCE_FILE" ]; then
            echo "File $SOURCE_FILE exists. Proceeding with the copy."

            # Ensure the destination directory exists
            if [ ! -d "$DEST_DIR" ]; then
                echo "Destination directory $DEST_DIR does not exist. Creating it."
                mkdir -p "$DEST_DIR"
                chmod 755 "$DEST_DIR"  # Set appropriate permissions for the directory
            fi

            # Copy the file to the destination
            cp "$SOURCE_FILE" "$DEST_DIR"

            # Set appropriate permissions for the copied file
            chmod 644 "$DEST_DIR/monitors.xml"
            chown gdm:gdm "$DEST_DIR/monitors.xml"  # Ensure the GDM user owns the file

            echo "File copied successfully to $DEST_DIR."
        else
            echo "File $SOURCE_FILE does not exist. No action taken."
        fi
      '';
      # Only enable if GDM is enabled
      enable = true;
      before = [ "display-manager.service" ];
      wantedBy = [ "display-manager.service" ];
    };
  };
}
