{ ... }:
{
  xdg = {
    enable = true;
    configFile."mimeapps.list".force = true;
    dataFile."applications/mimeapps.list".force = true;
    portal.xdgOpenUsePortal = true;
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
        "x-scheme-handler/nxm" = [ "com.nexusmods.app.desktop" ];
        "x-scheme-handler/http" = [ "firefox.desktop" ];
        "x-scheme-handler/https" = [ "firefox.desktop" ];


        "text/html" = [ "firefox.desktop" ];
        "text/plain" = [ "org.gnome.TextEditor.desktop" ];

        "image/png" = [ "org.gnome.eog.desktop" ];
        "image/jpeg" = [ "org.gnome.eog.desktop" ];
        "image/gif" = [ "org.gnome.eog.desktop" ];

        "audio/mpeg" = [ "vlc.desktop" ];
        "audio/flac" = [ "vlc.desktop" ];

        "video/mp4" = [ "vlc.desktop" ];
        "video/quicktime" = [ "vlc.desktop" ];
        "video/webm" = [ "vlc.desktop" ];
        "video/x-matroska" = [ "vlc.desktop" ];
        "video/x-flv" = [ "vlc.desktop" ];

        "inode/directory" = [ "org.gnome.Nautilus.desktop" ];
      };
    };
  };
}
