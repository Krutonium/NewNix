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
  config = mkIf (cfg.desktop == "budgie") {
    services = {
      xserver = {
        enable = true;
        displayManager = {
          lightdm = {
            enable = true;
            #greeters.gtk.enable = true;
            #wayland = cfg.wayland;
            #autoSuspend = cfg.autoSuspend;
          };
        };
        desktopManager = {
          budgie = {
            enable = true;
          };
        };
      };
    };
    hardware = {
      opengl = {
        enable = true;
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
  };
}
