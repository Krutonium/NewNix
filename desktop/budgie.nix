{ config, pkgs, lib, pkgs-budgie, ... }:
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
          gdm = {
            enable = true;
            wayland = false;
            autoSuspend = cfg.autoSuspend;
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
    environment.systemPackages = [ pkgs.qjackctl pkgs-budgie.budgie.budgie-desktop ];
  };
}
