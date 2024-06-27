{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.minecraft;
  ports = [ 25565 12345 ];
  location = "/persist/Gryphon";
  rconport = "12345";
  host = "127.0.0.1";
in
{
  config = mkIf (cfg.gryphon == true) {
    networking.firewall.allowedTCPPorts = ports;
    fileSystems."${location}" = {
      device = "/media2/Gryphon.btrfs";
      options = [ "compress=zstd:15" ];
    };
    systemd.services.gryphon = {
      description = "Gryphon Minecraft Server";
      serviceConfig = {
        Type = "simple";
        WorkingDirectory = "${location}/server/";
        User = "krutonium";
        Restart = "always";
        KillSignal = "SIGINT";
      };
      preStop =
        ''
          password=`cat /persist/mcrcon.txt`
          ${pkgs.mcrcon}/bin/mcrcon -H ${host} -P ${rconport} -p $password -w 5 "say Shutting Down Now!" stop
        '';
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      path = [ pkgs.jre pkgs.bash ];
      script =
        ''
          /media2/Gryphon/server/run.sh
        '';
    };

    systemd.services.snapshotter = {
      description = "Automatic Snapshots of Minecraft Server";
      serviceConfig = {
        type = "simple";
        WorkingDirectory = location;
        User = "root";
        KillSignal = "SIGINT";
      };
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.btrfs-progs pkgs.btrfs-snap pkgs.mcrcon pkgs.coreutils ];
      script =
        ''
          sleep 300
          password=`cat /persist/mcrcon.txt`
          mcrcon -H ${host} -P ${rconport} -p $password -w 1 "say Starting Hourly Backup..." save-off save-all
          # Create 1 snapshot per hour, and keep 24 of them.
          btrfs-snap -r -c ${location} hourly 24
          mcrcon -H ${host} -P ${rconport} -p $password -w 1 save-on "say Done!"
        '';
    };

    systemd.timers.snapshotter = {
      wantedBy = [ "timers.target" ];
      partOf = [ "snapshotter.service" ];
      timerConfig.OnCalendar = [ "hourly" ];
    };

    systemd.services.snapshotter-daily = {
      description = "Automatic Snapshots of Minecraft Server";
      serviceConfig = {
        type = "simple";
        WorkingDirectory = location;
        User = "root";
        KillSignal = "SIGINT";
      };
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.btrfs-progs pkgs.btrfs-snap pkgs.mcrcon pkgs.coreutils ];
      script =
        ''
          sleep 600
          password=`cat /persist/mcrcon.txt`
          mcrcon -H ${host} -P ${rconport} -p $password -w 1 "say Starting Daily Backup..." save-off save-all
          #Create 1 snapshot per day that is kept for 7 days.
          btrfs-snap -r -c ${location} daily 7
          mcrcon -H ${host} -P ${rconport} -p $password -w 1 "say Done!" save-on
          systemctl start snapshotter-send
        '';
    };
    systemd.timers.snapshotter-daily = {
      wantedBy = [ "timers.target" ];
      partOf = [ "snapshotter-daily.service" ];
      timerConfig.OnCalendar = [ "daily" ];
    };

    # Once per day, btrfs send ~/.snapshot to /media2/Gryphon/snapshots
    systemd.services.snapshotter-send = {
      description = "Send snapshots to backup server";
      serviceConfig = {
        type = "simple";
        WorkingDirectory = location;
        User = "root";
        KillSignal = "SIGINT";
      };
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.btrfs-progs pkgs.btrfs-snap pkgs.mcrcon pkgs.coreutils ];
      script = ''
        # Source and destination directories
        SOURCE_DIR="${location}.snapshots"
        DEST_DIR="/media2/Gryphon/snapshots"


        # Function to send a snapshot
        send_snapshot() {
          local snapshot_path=$1
          local snapshot_name=$(basename "$snapshot_path")

          echo "Sending snapshot $snapshot_name to $DEST_DIR"
          sudo btrfs send "$snapshot_path" | sudo btrfs receive "$DEST_DIR"

          if [ $? -eq 0 ]; then
            echo "Snapshot $snapshot_name sent successfully."
          else
            echo "Failed to send snapshot $snapshot_name."
          fi
        }

        # Function to remove obsolete snapshots
        remove_obsolete_snapshots() {
          echo "Checking for obsolete snapshots in $DEST_DIR"

          # List snapshots in the destination directory
          dest_snapshots=$(sudo btrfs subvolume list -p "$DEST_DIR" | grep 'path' | awk '{print $NF}')

          # List snapshots in the source directory
          cd "$SOURCE_DIR"
          source_snapshots=$(sudo btrfs subvolume list -p . | grep 'path' | awk '{print $NF}')

          for dest_snapshot in $dest_snapshots; do
            dest_snapshot_name=$(basename "$dest_snapshot")

            # Check if the snapshot exists in the source directory
            if ! echo "$source_snapshots" | grep -q "$dest_snapshot_name"; then
              echo "Removing obsolete snapshot $dest_snapshot_name from $DEST_DIR"
              sudo btrfs subvolume delete "$DEST_DIR/$dest_snapshot"

              if [ $? -eq 0 ]; then
                echo "Snapshot $dest_snapshot_name removed successfully."
              else
                echo "Failed to remove snapshot $dest_snapshot_name."
              fi
            fi
          done
        }

        # Remove obsolete snapshots before sending new ones
        remove_obsolete_snapshots

        # Get list of snapshots
        cd "$SOURCE_DIR"
        snapshots=$(sudo btrfs subvolume list -p . | grep 'path' | awk '{print $NF}')

        # Iterate through snapshots and send each one
        for snapshot in $snapshots; do
          send_snapshot "$SOURCE_DIR/$snapshot"
        done

        echo "All snapshots have been processed."
      '';
    };
  };
}
