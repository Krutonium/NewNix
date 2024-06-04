{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.desktop;
in
{
  config = mkIf (cfg.desktop == "hyprland") {
    programs = {
      hyprland = {
        enable = true;
        xwayland = {
          enable = true;
        };
      };
      hyprlock = {
        enable = true;
      };
    };
    services = {
      hypridle = {
        enable = true;
      };
    };
    hardware = {
      opengl = {
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
