{
  pkgs,
  ...
}:
{
  programs.plasma = {
    enable = true;
    shortcuts = {
      #      "services/org.flameshot.Flameshot.desktop".Capture = "Print";
      #      "services/org.kde.spectacle.desktop".RecordWindow = [ ];
    };
    configFile = {

    };
    dataFile = {
    };
  };
  home.packages = [
    pkgs.kdePackages.yakuake
    pkgs.kdePackages.kde-gtk-config
    pkgs.gsettings-desktop-schemas
    pkgs.dconf
    pkgs.dconf-editor
  ];
  dconf.settings."org/gnome/desktop/wm/preferences" = {
    button-layout = "appmenu:minimize,maximize,close";
  };
}
