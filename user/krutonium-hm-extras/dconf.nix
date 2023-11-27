# Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
{ lib, pkgs, ... }:

with lib.hm.gvariant;
let
  userTheme = "Adwaita-dark"; #Shell Theme
  mainTheme = "Adwaita-dark"; #Application Theme
  mainFont = "gg sans Normal 12";
  monoFont = "Ubuntu Mono 13";
  cursorTheme = "Bibata-Modern-Amber";
  iconTheme = "WhiteSur-dark";
  soundTheme = "freedesktop";
  superMenuLogo = "${./supermenu.png}";
  wallPaper = "file://${./wallpaper.png}";
in
{

  home.packages = [
    # Extensions
    pkgs.gnomeExtensions.dash-to-panel
    pkgs.gnomeExtensions.ddterm
    pkgs.gnomeExtensions.appindicator
    pkgs.gnomeExtensions.arcmenu
    pkgs.gnomeExtensions.no-overview
    pkgs.gnomeExtensions.adjust-display-brightness
    pkgs.gnomeExtensions.gtile

    # Other Stuff
    pkgs.gnome.gnome-tweaks
  ];

  dconf.settings = {
    "org/gnome/desktop/input-sources" = {
      sources = [ (mkTuple [ "xkb" "us" ]) ];
      xkb-options = [ "terminate:ctrl_alt_bksp" ];
    };

    "org/gnome/desktop/interface" = {
      clock-format = "12h";
      cursor-theme = cursorTheme;
      document-font-name = mainFont;
      font-antialiasing = "rgba";
      font-hinting = "full";
      font-name = mainFont;
      gtk-im-module = "gtk-im-context-simple";
      gtk-theme = userTheme;
      icon-theme = iconTheme;
      monospace-font-name = monoFont;
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      two-finger-scrolling-enabled = true;
    };

    "org/gnome/desktop/privacy" = {
      disable-microphone = false;
    };

    "org/gnome/desktop/sound" = {
      theme-name = soundTheme;
    };

    "org/gnome/desktop/wm/preferences" = {
      num-workspaces = 1;
      visual-bell = false;
      visual-bell-type = "frame-flash";
      audible-bell = false;
    };

    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:minimize,maximize,close";
      titlebar-font = mainFont;
    };

    "org/gnome/gnome-system-monitor" = {
      current-tab = "resources";
      maximized = false;
      network-in-bits = true;
      network-total-in-bits = true;
      show-dependencies = false;
      show-whose-processes = "user";
      window-state = mkTuple [ 700 551 ];
    };


    "org/gnome/gnome-system-monitor/proctree" = {
      columns-order = [ 0 1 2 3 4 6 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 ];
      sort-col = 8;
      sort-order = 0;
    };

    "org/gnome/mutter" = {
      attach-modal-dialogs = true;
      dynamic-workspaces = false;
      edge-tiling = true;
      focus-change-on-pointer-rest = true;
      overlay-key = "Super_L";
      workspaces-only-on-primary = true;
    };

    "org/gnome/shell" = {
      disabled-extensions = [ "apps-menu@gnome-shell-extensions.gcampax.github.com" ];
      enabled-extensions = [
        "dash-to-panel@jderose9.github.com"
        "arcmenu@arcmenu.com"
        "user-theme@gnome-shell-extensions.gcampax.github.com"
        "appindicatorsupport@rgcjonas.gmail.com"
        "no-overview@fthx"
        "gTile@vibou"
        #"gnome-extension-brightness@bruno.englert.gitlab.com"
        #"burn-my-windows@schneegans.github.com"
      ];
      # favorite-apps = [ "org.gnome.Nautilus.desktop" "firefox.desktop" "element-desktop.desktop" "discord.desktop" "telegramdesktop.desktop" "org.polymc.PolyMC.desktop" "com.obsproject.Studio.desktop" "idea-ultimate.desktop" "rider.desktop" ];
      favorite-apps = [ "org.gnome.Nautilus.desktop" "firefox.desktop" ];
      remember-mount-password = true;
    };

    "org/gnome/shell/extensions/arcmenu" = {
      arc-menu-placement = "DTP";
      available-placement = [ false true false ];
      custom-hot-corner-cmd = "sh -c 'notify-send \"$(date)\"'";
      custom-menu-button-icon-size = 35;
      custom-menu-button-icon = superMenuLogo;
      menu-button-icon = "Custom_Icon";
      hot-corners = "Disabled";
      menu-hotkey = "Super_L";
      override-hot-corners = true;
      #pinned-app-list = [ "Firefox" "" "firefox.desktop" "Terminal" "" "org.gnome.Terminal.desktop" "ArcMenu Settings" "ArcMenu_ArcMenuIcon" "gnome-extensions prefs arcmenu@arcmenu.com" ];
      pinned-app-list = [
        "Firefox"
        ""
        "firefox.desktop"
        "Steam"
        ""
        "steam.desktop"
        "Terminal"
        ""
        "org.gnome.Terminal.desktop"
        "Element"
        ""
        "element-desktop.desktop"
        "Telegram"
        ""
        "org.telegram.desktop.desktop"
        "Discord"
        ""
        "discord.desktop"
        "Prism Launcher"
        ""
        "org.prismlauncher.PrismLauncher.desktop"
        "OBS Studio"
        ""
        "com.obsproject.Studio.desktop"
        "IntelliJ IDEA"
        ""
        "idea-ultimate.desktop"
        "IntelliJ Rider"
        ""
        "rider.desktop"
      ];
    };
    "org/gnome/shell/extensions/burn-my-windows" = {
      active-profile = "/home/krutonium/.config/burn-my-windows/profiles/1685604429464762.conf";
    };
    "org/gnome/shell/extensions/dash-to-panel" = {
      animate-appicon-hover-animation-extent = "{'RIPPLE': 4, 'PLANK': 4, 'SIMPLE': 1}";
      appicon-margin = 4;
      appicon-padding = 6;
      group-apps = false;
      group-apps-label-font-size = 14;
      group-apps-label-max-width = 0;
      hotkeys-overlay-combo = "TEMPORARILY";
      leftbox-padding = -1;
      panel-anchors = ''
        {"0":"MIDDLE","1":"MIDDLE","2":"MIDDLE"}
      '';
      panel-element-positions = ''
        {"0":[{"element":"showAppsButton","visible":false,"position":"stackedTL"},{"element":"activitiesButton","visible":false,"position":"stackedTL"},{"element":"leftBox","visible":true,"position":"stackedTL"},{"element":"taskbar","visible":true,"position":"stackedTL"},{"element":"centerBox","visible":true,"position":"stackedBR"},{"element":"rightBox","visible":true,"position":"stackedBR"},{"element":"dateMenu","visible":true,"position":"stackedBR"},{"element":"systemMenu","visible":true,"position":"stackedBR"},{"element":"desktopButton","visible":true,"position":"stackedBR"}],"1":[{"element":"showAppsButton","visible":false,"position":"stackedTL"},{"element":"activitiesButton","visible":false,"position":"stackedTL"},{"element":"leftBox","visible":true,"position":"stackedTL"},{"element":"taskbar","visible":true,"position":"stackedTL"},{"element":"centerBox","visible":true,"position":"stackedBR"},{"element":"rightBox","visible":true,"position":"stackedBR"},{"element":"dateMenu","visible":true,"position":"stackedBR"},{"element":"systemMenu","visible":true,"position":"stackedBR"},{"element":"desktopButton","visible":true,"position":"stackedBR"}],"2":[{"element":"showAppsButton","visible":false,"position":"stackedTL"},{"element":"activitiesButton","visible":false,"position":"stackedTL"},{"element":"leftBox","visible":true,"position":"stackedTL"},{"element":"taskbar","visible":true,"position":"stackedTL"},{"element":"centerBox","visible":true,"position":"stackedBR"},{"element":"rightBox","visible":true,"position":"stackedBR"},{"element":"dateMenu","visible":true,"position":"stackedBR"},{"element":"systemMenu","visible":true,"position":"stackedBR"},{"element":"desktopButton","visible":true,"position":"stackedBR"}]}
      '';
      panel-lengths = ''
        {"0":100,"1":100,"2":100}
      '';
      panel-sizes = ''
        {"0":48,"1":48,"2":48}
      '';
      status-icon-padding = -1;
      tray-padding = -1;
      window-preview-title-position = "TOP";
    };

    "org/gnome/shell/extensions/user-theme" = {
      #name = userTheme;
    };

    "org/gnome/shell/weather" = {
      automatic-location = true;
      locations = "@av []";
    };

    "org/gnome/shell/world-clocks" = {
      locations = "@av []";
    };

    "org/gnome/tweaks" = {
      show-extensions-notice = false;
    };

    "org/gnome/desktop/background" = {
      color-shading-type = "solid";
      picture-opacity = 100;
      picture-options = "zoom";
      picture-uri = wallPaper;
      picture-uri-dark = wallPaper;
    };

    "org/gnome/desktop/interface" = {
      enable-hot-corners = false;
    };
  };
}
