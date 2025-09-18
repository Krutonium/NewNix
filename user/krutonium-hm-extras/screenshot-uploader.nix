{ config, pkgs, lib, ... }:
let
  screenshotUploader = pkgs.writeShellScriptBin "screenshot-uploader" ''
    #!/usr/bin/env bash
    set -euo pipefail

    watch_dir="$HOME/Pictures/Screenshots"
    remote_user="krutonium"
    remote_host="krutonium.ca"
    remote_dir="/media2/screenshots"
    base_url="https://screenshot.krutonium.ca"

    file="$1"
    local_path="${watch_dir}/$(basename "$file")"

    # Generate timestamped filename
    ts="$(date +%s-%N)"
    new_name="${ts}.png"
    new_path="${watch_dir}/${new_name}"

    # Rename locally
    mv "$local_path" "$new_path"

    # Upload with clean timestamped name
    scp "$new_path" "${remote_user}@${remote_host}:${remote_dir}/${new_name}"

    # Build public URL
    url="${base_url}/${new_name}"

    # Clipboard + notify
    echo -n "$url" | ${pkgs.xclip}/bin/xclip -selection clipboard
    ${pkgs.libnotify}/bin/notify-send "Screenshot uploaded" "$url"
  '';
in {
  home.packages = [ screenshotUploader ];

  systemd.user.services.screenshot-uploader = {
    Unit = {
      Description = "Upload new screenshot";
    };
    Service = {
      Type = "oneshot";
      #ExecStart = "${screenshotUploader}/bin/screenshot-uploader %f";
      ExecState = "${lib.getExe' screenshotUploader} %f";
    };
  };

  systemd.user.path.screenshot-uploader = {
    Unit = {
      Description = "Watch GNOME screenshots folder";
    };
    Path = {
      PathChanged = "%h/Pictures/Screenshots";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
