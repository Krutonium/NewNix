{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with builtins;
let
  cfg = config.sys.desktop;
in
{
  config = mkIf (cfg.desktop == "gnome") {
    services = {
        desktopManager = {
          gnome = {
            enable = true;
          };
      };
    };
    hardware = {
      graphics = {
        enable = true;
        enable32Bit = true;
      };
    };
    programs = {
      xwayland = {
        enable = true;
      };
    };
    security = {
      rtkit = {
        enable = true;
      };
    };
    environment.systemPackages = [ pkgs.qjackctl ];
  };
}
