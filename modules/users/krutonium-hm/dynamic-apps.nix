{ ... }:
{
  flake.homeModules.dynamic-apps =

    # https://github.com/vinceliuice/McMojave-circle/blob/master/src/apps/scalable/youtube-music-desktop-app.svg
    # Use that to find icon names
    # https://specifications.freedesktop.org/menu-spec/latest/category-registry.html
    # Valid Categories^
    # Alt + F2, `lg` select Windows and find the window class for WMCLass to fix icons.
    { pkgs, ... }:
    let
      inherit (builtins) parseDrvName listToAttrs map;
      appPkgs = [
        {
          pkg = pkgs.youtube-music;
          prettyName = "YouTube Music";
          iconName = "youtube-music-desktop-app";
          category = "AudioVideo";
          startupWMClass = "com.github.th_ch.youtube_music";
        }
        {
          pkg = pkgs.ungoogled-chromium;
          prettyName = "UnGoogled Chromium";
          iconName = "google-chrome";
          category = "Network";
          startupWMClass = "chromium-browser";
        }
        {
          pkg = pkgs.calibre;
          prettyName = "Calibre E-Book Reader";
          iconName = "calibre-gui";
          category = "Education";
          startupWMClass = "calibre-gui";

        }
        {
          pkg = pkgs.dolphin-emu;
          prettyName = "Dolphin";
          iconName = "dolphin-emu";
          category = "Game";
        }
        {
          pkg = pkgs.plex-desktop;
          prettyName = "Plex";
          iconName = "plex";
          category = "AudioVideo";
          startupWMClass = "Plex";
        }
        {
          pkg = pkgs.plezy;
          prettyName = "Plezy";
          iconName = "plex";
          category = "AudioVideo";
          startupWMClass = "com.edde746.plezy"
        }
      ];

      apps = map (
        appSpec:
        let
          pkg = appSpec.pkg;
          fallbackName = (parseDrvName pkg.name).name;
          meta = pkg.meta or { };
          mainProgram = meta.mainProgram or fallbackName;
          prettyName = appSpec.prettyName or fallbackName;
          iconName = appSpec.iconName or meta.icon or mainProgram;
          category = appSpec.category or "Utility";
          terminal = appSpec.terminal or "False";
          StartupWMClass = appSpec.startupWMClass or "";
        in
        {
          name = "${mainProgram}.desktop";
          value = {
            text = ''
              [Desktop Entry]
              Version=1.0
              Type=Application
              Name=${prettyName}
              Comment=${meta.description or "Run ${prettyName}"}
              Exec=sh -c 'notify-send "Launching ${prettyName}..." & NIXPKGS_ALLOW_UNFREE=1 nix run nixpkgs#${mainProgram} --impure -- %U'
              Icon=${iconName}
              Terminal=${terminal}
              Categories=${category};
              StartupWMClass=${StartupWMClass}
            '';
          };
        }
      ) appPkgs;
    in
    {
      home.file = listToAttrs (
        map (app: {
          name = ".local/share/applications/${app.name}";
          value = app.value;
        }) apps
      );
      home.packages = [ pkgs.libnotify ];
    };
}
