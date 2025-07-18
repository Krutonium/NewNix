{ pkgs, ... }:
let
  apps = [
    {
      name = "Calibre";
      pkg = "calibre";
      icon = "calibre";
      comment = "E-book Library Manager";
    }
  ];
in
{
  home.packages = [ pkgs.zenity ];
  home.file = builtins.listToAttrs (
    map (app: {
      name = ".local/share/applications/${app.pkg}.desktop";
      value.text = ''
        [Desktop Entry]
        Version=1.0
        Type=Application
        Name=${app.name}
        Comment=${app.comment}
        Exec=sh -c 'zenity --info --text="Launching ${app.name}..." --timeout=2; nix run nixpkgs#${app.pkg}'
        Icon=${app.icon}
        Terminal=true
        Categories=Utility;
      '';
    }) apps
  );
}
