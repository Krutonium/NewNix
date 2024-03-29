{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.desktop;
in
{
  config = mkIf (cfg.displayManager == "gdm") {
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
      };
    };
  };
}
