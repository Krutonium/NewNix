{ config, pkgs, ... }:
{
  xdg.configFile."mimeapps.list".force = true;
  xdg.dataFile."applications/mimeapps.list".force = true;
  xdg = {
    enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "application/vnd.rar" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-7z-compressed" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-compressed-tar" = [ "org.gnome.FileRoller.desktop" ];
        "application/zip" = [ "org.gnome.FileRoller.desktop" ];
        "application/pdf" = [ "firefox.desktop" ];
        "application/json" = [ "org.gnome.TextEditor.desktop" ];
        "application/x-cd-image" = [ "gnome-disk-image-mounter.desktop" ];
        "application/x-rar" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-ms-dos-executable" = [ "wine.desktop" ];

        "text/html" = [ "firefox.desktop" ];
        "text/plain" = [ "org.gnome.TextEditor.desktop" ];

        "image/png" = [ "org.gnome.eog.desktop" ];
        "image/jpeg" = [ "org.gnome.eog.desktop" ];
        "image/gif" = [ "org.gnome.eog.desktop" ];

        "audio/mpeg" = [ "vlc.desktop" ];
        "audio/flac" = [ "vlc.desktop" ];

        "video/mp4" = [ "vlc.desktop" ];
        "video/quicktime" = [ "vlc.desktop" ];

        "inode/directory" = [ "org.gnome.Nautilus.desktop" ];
      };
    };
  };
}
