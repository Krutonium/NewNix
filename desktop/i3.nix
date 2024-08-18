{ config, pkgs, lib, ... }:
with lib;
with builtins;
let
  cfg = config.sys.desktop;
in
{
  config = mkIf (cfg.desktop == "i3") {
  environment.pathsToLink = [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw 
    services = {
      xserver = {
        enable = true;
        displayManager = {
          defaultSession = "none+i3";
        };
        windowManager = {
          i3 = {
            enable = true;
            extraPackages = with pkgs; 
            [ 
              i3status
              i3lock
              dmenu 
              i3blocks 
            ];
          };
        };
      };
    };
    hardware = {
      opengl = {
        enable = true;
        driSupport32Bit = true;
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