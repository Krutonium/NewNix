{ pkgs, ... }:
let
  inherit (builtins) parseDrvName listToAttrs map;
  appPkgs = [
    pkgs.calibre
    pkgs.gimp
  ];
  apps = map
    (pkg:
      let
        fallbackName = (parseDrvName pkg.name).name;
        meta = pkg.meta or { };
      in
      {
        name = "${meta.mainProgram or fallbackName}.desktop";
        value = {
          text = ''
            [Desktop Entry]
            Version=1.0
            Type=Application
            Name=${fallbackName}
            Comment=${meta.description or "Run ${fallbackName}"}
            Exec=sh -c 'notify-send "Launching ${meta.name or fallbackName}..." & nix run nixpkgs#${fallbackName}'
            Icon=${meta.icon or meta.mainProgram or fallbackName}
            Terminal=false
            Categories=Utility;
          '';
        };
      }) appPkgs;
in
{
  home.file = listToAttrs (map
    (app: {
      name = ".local/share/applications/${app.name}";
      value = app.value;
    })
    apps);
  home.packages = [ pkgs.libnotify ];
}
