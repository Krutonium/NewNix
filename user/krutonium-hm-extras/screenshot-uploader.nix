{ config, pkgs, lib, ... }:
let
  screenshotUploader = pkgs.writeShellScriptBin "screenshot-uploader" ''
    #!/usr/bin/env bash
    set -euo pipefail

    watch_dir="$HOME/Pictures/Screenshots"
    remote_user="krutonium"
    remote_host="krutonium.ca"
    remote_dir="/media2/screenshots"
    base_url="https://scr.krutonium.ca"

    # newest png file
    file=""
    for f in "$watch_dir"/*.png; do
      [ -e "$f" ] || continue
        if [[ -z $file || $f -nt $file ]]; then
        file=$f
      fi
    done

    if [[ -n $file ]]; then
      echo "$file"
    else
      echo "No PNG files found" >&2
      exit 1
    fi

    local_path="$watch_dir/$(basename "$file")"
    echo Uploading $local_path

    # Upload with clean timestamped name
    echo "Uploading $local_path to $remote_dir
    scp "$local_path" "$remote_user@$remote_host:$remote_dir/

    # Build public URL
    url="$base_url/$new_name"

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
      ExecStart = "${screenshotUploader}/bin/screenshot-uploader %f";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
  systemd.user.paths.screenshot-uploader = {
    Unit = {
      Description = "Watch GNOME screenshots folder";
    };
    Path = {
      PathChanged = "${config.home.homeDirectory}/Pictures/Screenshots";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
