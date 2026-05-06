{ ... }:
{
  flake.homeModules.dynamic-apps =

    # https://github.com/vinceliuice/McMojave-circle/blob/master/src/apps/scalable/youtube-music-desktop-app.svg
    # Use that to find icon names
    # https://specifications.freedesktop.org/menu-spec/latest/category-registry.html
    # Valid Categories
    { pkgs, ... }:
    let
      inherit (builtins) parseDrvName listToAttrs map;
      appPkgs = [
        {
          pkg = pkgs.youtube-music;
          prettyName = "YouTube Music";
          iconName = "youtube-music-desktop-app";
          category = "AudioVideo";
        }
        {
          pkg = pkgs.ungoogled-chromium;
          prettyName = "UnGoogled Chromium";
          iconName = "google-chrome";
          category = "Network";
        }
        {
          pkg = pkgs.calibre;
          prettyName = "Calibre E-Book Reader";
          iconName = "calibre-gui";
          category = "Education";
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
              Exec=sh -c 'notify-send "Launching ${prettyName}..." & nix run nixpkgs#${mainProgram} -- %U'
              Icon=${iconName}
              Terminal=${terminal}
              Categories=${category};
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