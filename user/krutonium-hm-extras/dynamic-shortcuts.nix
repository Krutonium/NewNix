{ pkgs, ... }:
let
  inherit (builtins) parseDrvName listToAttrs map;
  # List of applications with optional prettyName and iconName
  appPkgs = [
    {
      # The only required field.
      pkg = pkgs.youtube-music;
      # Whatever you think the appropriate name is
      prettyName = "YouTube Music";
      # https://github.com/vinceliuice/McMojave-circle/blob/master/src/apps/scalable/youtube-music-desktop-app.svg
      iconName = "youtube-music-desktop-app";
      # https://specifications.freedesktop.org/menu-spec/latest/category-registry.html
      category = "AudioVideo";
    }
    #{
      #pkg = pkgs.vesktop;
    #}
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
          Exec=sh -c 'notify-send "Launching ${prettyName}..." & nix run nixpkgs#${mainProgram}'
          Icon=${iconName}
          Terminal=false
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
}
