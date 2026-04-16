{
  pkgs,
  ...
}:
{
  programs.plasma = {
    enable = true;
    overrideConfig = true;
    shortcuts = {
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
