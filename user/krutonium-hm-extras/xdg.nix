{ config, pkgs, ...}:
{
  home.xdg = {
    enable = true;
    mimeapps = {
      enable = true;
      defaultapplications = {
        "application/vnd.rar" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-7z-compressed" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-compressed-tar" = [ "org.gnome.FileRoller.desktop" ];
        "application/zip" = [ "org.gnome.FileRoller.desktop" ];
        "text" = [ "org.gnome.TextEditor.desktop" ]; 
      };
    };
  };
}
