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
        excludePackages = [ ];
        displayManager = {
          gdm = {
            enable = true;
            wayland = cfg.wayland;
            autoSuspend = cfg.autoSuspend;
          };
          autoLogin = {
            user = "krutonium";
            enable = true;
          };
        };
      };
    };
  };
}
