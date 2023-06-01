{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.desktop;
in
{
  config = mkIf (cfg.desktop == "gnome") {
    services = {
      xserver = {
        enable = true;
        excludePackages = [ pkgs.xterm ];
        displayManager = {
          gdm = {
            enable = true;
            wayland = cfg.wayland;
            autoSuspend = cfg.autoSuspend;
          };
        };
        desktopManager = {
          gnome = {
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
    environment.systemPackages = [ pkgs.qjackctl ];
  };
}
