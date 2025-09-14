{
  lib,
  pkgs,
  osConfig,
  ...
}:

with lib.hm.gvariant;
let
  superMenuLogo = "${./assets/supermenu.png}";
  wallPaper = "file://${./assets/wallpaper.png}";
  extensions = [
    pkgs.gnomeExtensions.dash-to-panel
    pkgs.master.gnomeExtensions.ddterm
    pkgs.gnomeExtensions.appindicator
    pkgs.master.gnomeExtensions.arcmenu
    pkgs.gnomeExtensions.no-overview
    pkgs.gnomeExtensions.gtile
    pkgs.gnomeExtensions.user-themes
    pkgs.gnomeExtensions.brightness-control-using-ddcutil
    pkgs.gnomeExtensions.compiz-windows-effect
    pkgs.gnomeExtensions.compiz-alike-magic-lamp-effect
  ];
  extensionUuids = map (ext: ext.extensionUuid) extensions;

  # Detect whether GNOME is enabled in the system configuration
  isGnome = (osConfig.sys.desktop.desktop == "gnome");
in
lib.mkIf isGnome {
  home.packages = [
    pkgs.gnome-tweaks
    pkgs.cascadia-code # Font
  ]
  ++ extensions;
  dconf.settings = {
    "org/gnome/desktop/input-sources" = {
      sources = [
        (mkTuple [
          "xkb"
          "us"
        ])
      ];
      xkb-options = [ "terminate:ctrl_alt_bksp" ];
    };
    "org/gnome/desktop/interface" = {
      clock-format = "12h";
      font-antialiasing = "rgba";
      font-hinting = "full";
      gtk-im-module = "gtk-im-context-simple";
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      two-finger-scrolling-enabled = true;
    };

    "org/gnome/desktop/privacy" = {
      disable-microphone = false;
    };

    "org/gnome/desktop/wm/preferences" = {
      num-workspaces = 1;
      visual-bell = false;
      visual-bell-type = "frame-flash";
      audible-bell = false;
      focus-new-windows = "smart";
      auto-raise = true;
      auto-raise-delay = 50;
    };

    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:minimize,maximize,close";
      #titlebar-font = mainFont;
    };

    "org/gnome/gnome-system-monitor" = {
      current-tab = "resources";
      maximized = false;
      network-in-bits = true;
      network-total-in-bits = true;
      show-dependencies = false;
      show-whose-processes = "user";
      window-state = mkTuple [
        700
        551
      ];
    };

    "org/gnome/gnome-system-monitor/proctree" = {
      columns-order = [
        0
        1
        2
        3
        4
        6
        8
        9
        10
        11
        12
        13
        14
        15
        16
        17
        18
        19
        20
        21
        22
        23
        24
        25
        26
      ];
      sort-col = 8;
      sort-order = 0;
    };

    "org/gnome/mutter" = {
      attach-modal-dialogs = false;
      dynamic-workspaces = false;
      edge-tiling = true;
      focus-change-on-pointer-rest = true;
      overlay-key = "Super_L";
      workspaces-only-on-primary = true;
      experimental-features = [ "variable-refresh-rate" "dma-buf-screen-sharing" ];
    };

    "com/github/amezin/ddterm" = {
      ddterm-toggle-hotkey = [
        "Page_Down"
      ];
      panel-icon-type = "none";
    };

    "org/gnome/shell" = {
      disabled-extensions = [ "apps-menu@gnome-shell-extensions.gcampax.github.com" ];
      enabled-extensions = extensionUuids;
      # favorite-apps = [ "org.gnome.Nautilus.desktop" "firefox.desktop" "element-desktop.desktop" "discord.desktop" "telegramdesktop.desktop" "org.polymc.PolyMC.desktop" "com.obsproject.Studio.desktop" "idea-ultimate.desktop" "rider.desktop" ];
      favorite-apps = [
        "org.gnome.Nautilus.desktop"
        "firefox.desktop"
      ];
      remember-mount-password = true;
    };
    "org/gnome/shell/extensions/display-brightness-ddcutil" = {
      button-location = 1;
      only-all-slider = true;
      position-system-menu = 3;
      show-all-slider = true;
      show-value-label = true;
    };
    "org/gnome/shell/extensions/arcmenu" = {
      arc-menu-placement = "DTP";
      available-placement = [
        false
        true
        false
      ];
      custom-hot-corner-cmd = "sh -c 'notify-send \"$(date)\"'";
      custom-menu-button-icon-size = 35;
      custom-menu-button-icon = superMenuLogo;
      menu-button-icon = "Custom_Icon";
      hot-corners = "Disabled";
      menu-hotkey = "Super_L";
      override-hot-corners = true;
      # [
      #   (mkDictionaryEntry [ "id" "gnome-extensions prefs arcmenu@arcmenu.com" ])
      #   (mkDictionaryEntry [ "name" "ArcMenu Settings" ])
      #   (mkDictionaryEntry [ "icon" "ArcMenu_ArcMenuIcon" ])
      # ]
      pinned-apps = [
        [
          (mkDictionaryEntry [
            "id"
            "firefox.desktop"
          ])
        ]
        [
          (mkDictionaryEntry [
            "id"
            "org.gnome.Nautilus.desktop"
          ])
        ]
        [
          (mkDictionaryEntry [
            "id"
            "org.gnome.Console.desktop"
          ])
          (mkDictionaryEntry [
            "icon"
            "terminal"
          ])
        ]

        [
          (mkDictionaryEntry [
            "id"
            "org.gnome.Fractal.desktop"
          ])
        ]
        [
          (mkDictionaryEntry [
            "id"
            "vesktop.desktop"
          ])
          (mkDictionaryEntry [
            "icon"
            "dev.vencord.Vesktop"
          ])

        ]
        [
          (mkDictionaryEntry [
            "id"
            "org.prismlauncher.PrismLauncher.desktop"
          ])
        ]
        [
          (mkDictionaryEntry [
            "id"
            "com.obsproject.Studio.desktop"
          ])
        ]
        [
          (mkDictionaryEntry [
            "id"
            "idea-ultimate.desktop"
          ])
          (mkDictionaryEntry [
            "name"
            "IDEA"
          ])
          (mkDictionaryEntry [
            "icon"
            "idea"
          ])
        ]
        [
          (mkDictionaryEntry [
            "id"
            "rider.desktop"
          ])
          (mkDictionaryEntry [
            "icon"
            "rider"
          ])
        ]
      ];
    };
    "org/gnome/shell/extensions/monitor-brightness-volume" = {
      show-volume = false;
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
