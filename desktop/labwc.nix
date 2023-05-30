{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.desktop;
in
{
  config = mkIf (cfg.desktop == "labwc") {
    environment.systemPackages = with pkgs; [ waybox ];
    services = {
      xserver = {
        enable = true;
        displayManager = {
          gdm = {
            enable = true;
            wayland = true;
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
  };
}
