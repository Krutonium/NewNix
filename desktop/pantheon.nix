{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.desktop;
in
{
  config = mkIf (cfg.desktop == "pantheon") {
    services.xserver = {
      displayManager.lightdm.enable = true;
      desktopManager.pantheon.enable = true;
    };
  };
}