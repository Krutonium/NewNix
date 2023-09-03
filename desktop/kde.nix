{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.desktop;
in
{
  config = mkIf (cfg.desktop == "kde") {
    services = {
      xserver = {
        enable = true;
        displayManager = {
          sddm = {
            enable = true;
          };
        };
        desktopManager = {
          plasma5 = {
            enable = true;
          };
        };
      };
    };
    hardware = {
      opengl = {
        enable = true;
        extraPackages = [ pkgs.master.mesa ];
        extraPackages32 = [ pkgs.master.pkgsi686Linux.mesa ];
      };
    };
    security = {
      rtkit = {
        enable = true;
      };
    };
    environment.systemPackages = [ pkgs.flameshot ];
  };
}
